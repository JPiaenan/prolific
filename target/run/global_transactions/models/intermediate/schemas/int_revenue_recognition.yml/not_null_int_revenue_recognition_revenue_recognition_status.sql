
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select revenue_recognition_status
from main_intermediate."int_revenue_recognition"
where revenue_recognition_status is null



  
  
      
    ) dbt_internal_test