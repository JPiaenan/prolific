
    
    

with all_values as (

    select
        discount_application_status as value_field,
        count(*) as n_records

    from main_marts."mart_monthly_revenue"
    group by discount_application_status

)

select *
from all_values
where value_field not in (
    'Discount Applied','Contract Active - Threshold Not Met','No Contract'
)


