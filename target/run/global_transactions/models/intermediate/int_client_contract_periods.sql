
  
    
    
    create  table main_intermediate."int_client_contract_periods"
    as
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
    from main_intermediate."int_transactions_with_gbp_amounts" t
    left join main_staging."stg_client_contracts" c
        on t.client_id = c.client_id

)
  ,
  b as (  select
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
  )

  select *,
       case when has_active_contract = 1 and cumulative_spend_in_contract >= spend_threshold
        then 1 else 0  end as spend_threshold_met
       from b;

  