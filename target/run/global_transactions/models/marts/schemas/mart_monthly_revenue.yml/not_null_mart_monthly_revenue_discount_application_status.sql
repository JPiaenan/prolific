
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select discount_application_status
from main_marts."mart_monthly_revenue"
where discount_application_status is null



  
  
      
    ) dbt_internal_test