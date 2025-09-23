
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select transaction_amount
from main_intermediate."int_revenue_recognition"
where transaction_amount is null



  
  
      
    ) dbt_internal_test