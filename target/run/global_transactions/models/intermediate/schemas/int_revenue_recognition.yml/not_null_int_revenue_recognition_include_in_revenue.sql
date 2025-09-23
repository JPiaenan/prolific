
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select include_in_revenue
from main_intermediate."int_revenue_recognition"
where include_in_revenue is null



  
  
      
    ) dbt_internal_test