
    
    

with all_values as (

    select
        fee_status as value_field,
        count(*) as n_records

    from main_intermediate."int_transactions_with_fees"
    group by fee_status

)

select *
from all_values
where value_field not in (
    'Discounted','Standard (Contract Active)','Standard (No Contract)'
)


