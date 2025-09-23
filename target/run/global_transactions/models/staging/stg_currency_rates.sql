
  
    
    
    create  table main_staging."stg_currency_rates"
    as
        with source as (
    select * from main."currency_rates"
),

src_currency_rates as (
    select
        currency,
        date(rate_date) as rate_date,
        exchange_rate_to_gbp
        
    from source
)

select * from src_currency_rates

  