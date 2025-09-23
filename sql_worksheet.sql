--- this is a scratchpad for ad-hoc queries to explore the data and validate assumptions in datagrip ---
--- not part of the dbt project ---


select * from transactions; --600
;
select distinct transaction_type, count(*)
from transactions
group by 1

;

    ---
-- chargeback,60
-- fraud,30
-- payment,420
-- refund,90


    -- transaction date format 2024-01-01
    -- all platform fee margin 0.2

    -- linked transstion id - 69 not null  -- all refunds linked
;

select * from transaction_resolutions;

select distinct resolution_status from transaction_resolutions;
--resolved
-- pending

--07/02/2024 resoltion date format

select * from currency_rates;

select * from client_contracts;
--

C001,2024-01-01,12,2500000,0.175
C002,2024-01-01,6,2800000,0.18
C003,2024-02-01,12,3200000,0.185
C004,2024-03-01,9,3500000,0.19
--
-- assume spend_threshold met -> discount
-- start_date + duration = end date
-- contract start date format 2024-01-01

--
select
        t.*,
        cr.exchange_rate_to_gbp
    from transactions t
    left join currency_rates cr
        on t.transaction_date = cr.rate_date
        and t.currency = cr.currency

---covert to gbp only




;

ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_staging.db' AS staging_db;
;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_intermediate.db' AS intermediate_db;


;
select count(*) from int_transactions_with_gbp_amounts  --600
;

---- contract cals
    select
        client_id,
        contract_start_date,
        contract_duration_months,
        spend_threshold,
        discounted_fee_margin,
        date(contract_start_date, '+' || contract_duration_months || ' months') as contract_end_date
    from client_contracts
;

--- check if transaction client has contract
-- 162 has contract at transaction
 select
        t.*,
      c.*,
--        date(contract_start_date, '+' || contract_duration_months || ' months') as contract_end_date
        case when c.contract_start_date is not null
     and t.transaction_date >= c.contract_start_date
and t.transaction_date < date(contract_start_date, '+' || contract_duration_months || ' months')
            then 1 else 0 end as has_active_contract
    from int_transactions_with_gbp_amounts t
    left join client_contracts c
        on t.client_id = c.client_id

   ;

--- trying to find out how much customer spent during contract
with a as (

     select
        t.*,
      c.*,
--        date(contract_start_date, '+' || contract_duration_months || ' months') as contract_end_date
        case when c.contract_start_date is not null
     and t.transaction_date >= c.contract_start_date
and t.transaction_date < date(contract_start_date, '+' || contract_duration_months || ' months')
            then 1 else 0 end as has_active_contract
    from int_transactions_with_gbp_amounts t
    left join client_contracts c
        on t.client_id = c.client_id

)
    select
        *,transaction_amount_gbp,
--         case when has_active_contract = 1 then
--                   sum(case when transaction_type = 'payment' then transaction_amount_gbp else 0 end)
--                 over ( partition by client_id, contract_start_date order by transaction_date, transaction_id) else 0 end total,
 case when has_active_contract = 1 then
               sum(case when transaction_type = 'payment' then transaction_amount_gbp else 0 end)
                over ( partition by client_id, contract_start_date order by transaction_date, transaction_id rows unbounded preceding ) else 0 end as cumulative_spend_in_contract

        -- Check if spend threshold is met
--     ,case when has_active_contract = 1 and cumulative_spend_in_contract >= spend_threshold
--         then 1 else 0  end as spend_threshold_met

    from a
order by client_id, contract_start_date,transaction_date,transaction_id

---- NOTE : may need to round transaction_amount_gbp to 2 dp  at the end but leave it for now
;



SELECT
    t.*,
    c.spend_threshold,
    c.discounted_fee_margin
FROM staging_db.stg_transactions t
LEFT JOIN main.client_contracts c
    ON t.client_id = c.client_id

;


select
*,

    -- Determine which fee margin to apply -  assumption: in the contract period, if threshold met, discounted fee applies, other wise standard (platform) fee applies
    case  when spend_threshold_met = 1 then discounted_fee_margin
        else platform_fee_margin end as applied_fee_margin,

    -- Calculate actual platform fee based on applied margin
    round(
        transaction_amount_gbp *
        case when spend_threshold_met = 1 then discounted_fee_margin
            else platform_fee_margin end, 2) as actual_platform_fee_gbp,

    -- Calculate fee savings from discount
    round(
        transaction_amount_gbp * (platform_fee_margin -
            case when spend_threshold_met = 1 then discounted_fee_margin
                else platform_fee_margin end ), 2 ) as fee_discount_savings_gbp,

    -- Flag transactions getting discount
    case
        when spend_threshold_met = 1 then 'discounted'
        when has_active_contract = 1 then 'standard_contract'
        else 'Standard_no_contract'
    end as fee_status

from int_client_contract_periods



;

------ fees and calculations assumptions
select  t.transaction_id, t.linked_transaction_id, t.transaction_type, tr.*
from int_transactions_with_fees t
left join stg_transaction_resolutions tr
    on t.transaction_id = tr.transaction_id

-- it should be fine not to link with linked_transaction_id unless the final report needs to see the chain
-- works with  high level overview / aggregaated measures


-- 1. Handle multiple transaction types (payments, refunds, fraud, chargebacks)
-- 2. Apply correct platform fee margins based on client contracts
-- 3. Convert all amounts to GBP using daily exchange rates
-- 4. Calculate monthly revenue recognising only resolved chargebacks


-- chargeback,60
-- fraud,30
-- payment,420
-- refund,90

--  Assumption :
--  revenue - resolved chargebacks, payment,refund
--  gmv -
;

SELECT transaction_type, COUNT(*) as count,
       COUNT(CASE WHEN linked_transaction_id IS NOT NULL AND linked_transaction_id != '' THEN 1 END) as with_links
FROM transactions GROUP BY transaction_type

-- chargeback,60,0
-- fraud,30,0
-- payment,420,0
-- refund,90,90
;

SELECT transaction_id, transaction_type, linked_transaction_id, transaction_amount, client_id
FROM transactions WHERE transaction_type = 'refund' LIMIT 5;


---- dbt test debug
select transaction_amount_gbp, *
from int_client_contract_periods
where transaction_amount_gbp is null
;

select transaction_amount_gbp,exchange_rate_to_gbp, *
from int_transactions_with_gbp_amounts
where transaction_amount_gbp is null
;
---- this is due to transaction date not in currency_rates.csv
---- making 1 as default for GBP to GBP as the 4 affected records are all in GBP anyway



--- check how final model look like

ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_marts.db' AS marts_db;
select * from marts_db.mart_monthly_revenue;

--- check discount applied

ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_staging.db' AS staging_db;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_intermediate.db' AS intermediate_db;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_marts.db' AS marts_db;

-- Try without schema prefix
SELECT * FROM int_revenue_recognition;;
--- okay no one meets threshold
-- SELECT name FROM intermediate_db.sqlite_master WHERE type='table';

-- Detach each database (except main which cannot be detached)
-- Note: We're not using IF EXISTS since your SQLite version may not support it
DETACH DATABASE staging_db;
DETACH DATABASE intermediate_db;
DETACH DATABASE marts_db;

-- Check if they're detached

-- Now re-attach them
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_staging.db' AS staging_db;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_intermediate.db' AS intermediate_db;
ATTACH DATABASE '/Users/jiaen.pan/Projects/prolific/ae-assessment/target/main_marts.db' AS marts_db;

-- Verify attachments


SELECT * FROM int_revenue_recognition LIMIT 5;  -- From main (intermediate)
SELECT * FROM staging_db.stg_transactions LIMIT 5;  -- From staging
SELECT * FROM marts_db.mart_monthly_revenue LIMIT 5;  -- From marts
