
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select fee_discount_savings_gbp
from main_intermediate."int_transactions_with_fees"
where fee_discount_savings_gbp is null



  
  
      
    ) dbt_internal_test