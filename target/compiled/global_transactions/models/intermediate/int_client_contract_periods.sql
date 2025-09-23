

with transactions_gbp as (
    select * from main_intermediate."int_transactions_with_gbp_amounts"
),

client_contracts as (
    select * from main_staging."stg_client_contracts"
),

-- Calculate contract end dates
contracts_with_periods as (
    select 
        client_id,
        contract_start_date,
        contract_duration_months,
        spend_threshold,
        discounted_fee_margin,
        date(contract_start_date, '+' || contract_duration_months || ' months') as contract_end_date
    from client_contracts
),

-- Join transactions with their applicable contracts
transactions_with_contracts as (
    select 
        t.*,
        c.contract_start_date,
        c.contract_end_date,
        c.spend_threshold,
        c.discounted_fee_margin,
        case 
            when c.contract_start_date is not null 
                and t.transaction_date >= c.contract_start_date 
                and t.transaction_date < c.contract_end_date
            then 1 
            else 0 
        end as has_active_contract
    from transactions_gbp t
    left join contracts_with_periods c 
        on t.client_id = c.client_id
),

-- Calculate cumulative spend within contract periods for threshold tracking
---- NOTE : may need to round transaction_amount_gbp to 2 dp  at the end but leave it for now

transactions_with_cumulative_spend as (
    select 
        *,
        case 
            when has_active_contract = 1 then
                sum(case when transaction_type = 'payment' then transaction_amount_gbp else 0 end) 
                over (
                    partition by client_id, contract_start_date 
                    order by transaction_date, transaction_id
                    rows unbounded preceding
                )
            else 0
        end as cumulative_spend_in_contract
    from transactions_with_contracts
)

select 
    transaction_id,
    client_id,
    transaction_amount,
    transaction_type,
    transaction_date,
    platform_fee_margin,
    original_currency,
    linked_transaction_id,
    exchange_rate_to_gbp,
    transaction_amount_gbp,
    platform_fee_gbp,
    contract_start_date,
    contract_end_date,
    spend_threshold,
    discounted_fee_margin,
    has_active_contract,
    round(cumulative_spend_in_contract, 2) as cumulative_spend_in_contract,

    -- Check if spend threshold is met
    case 
        when has_active_contract = 1 and cumulative_spend_in_contract >= spend_threshold 
        then 1 
        else 0 
    end as spend_threshold_met
    
from transactions_with_cumulative_spend