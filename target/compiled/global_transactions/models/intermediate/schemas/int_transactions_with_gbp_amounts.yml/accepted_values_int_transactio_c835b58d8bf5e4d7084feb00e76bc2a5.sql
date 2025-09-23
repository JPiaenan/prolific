
    
    

with all_values as (

    select
        transaction_type as value_field,
        count(*) as n_records

    from main_intermediate."int_transactions_with_gbp_amounts"
    group by transaction_type

)

select *
from all_values
where value_field not in (
    'payment','refund','chargeback','fraud'
)


