
    
    

with all_values as (

    select
        transaction_type as value_field,
        count(*) as n_records

    from main_intermediate."int_revenue_recognition"
    group by transaction_type

)

select *
from all_values
where value_field not in (
    'payment','refund','chargeback','fraud'
)


