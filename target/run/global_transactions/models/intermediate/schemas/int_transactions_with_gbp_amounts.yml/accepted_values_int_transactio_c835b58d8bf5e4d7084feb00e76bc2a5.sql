
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    

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



  
  
      
    ) dbt_internal_test