
  
    
    
    create  table main_intermediate."int_transactions_with_gbp_amounts"
    as
        

with 
transactions as (
    select * from main_staging."stg_transactions"
),

currency_rates as (
    select * from main_staging."stg_currency_rates"
),

transactions_with_rates as (
    select 
        t.*,
        cr.exchange_rate_to_gbp
    from transactions t
    left join currency_rates cr 
        on t.transaction_date = cr.rate_date
        and t.currency = cr.currency
)

select 
    transaction_id,
    client_id,
    transaction_amount,
    transaction_type,
    transaction_date,
    platform_fee_margin,
    currency as original_currency,
    linked_transaction_id,
    exchange_rate_to_gbp,
    
    -- Convert amount to GBP
    round(transaction_amount * exchange_rate_to_gbp, 2) as transaction_amount_gbp,
    
    -- Calculate platform fee in GBP
    round(transaction_amount * exchange_rate_to_gbp * platform_fee_margin, 2) as platform_fee_gbp
    
from transactions_with_rates

  