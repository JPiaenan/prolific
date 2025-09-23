
    
    

with all_values as (

    select
        contract_status as value_field,
        count(*) as n_records

    from main_marts."mart_monthly_revenue"
    group by contract_status

)

select *
from all_values
where value_field not in (
    'Active Contract','No Contract'
)


