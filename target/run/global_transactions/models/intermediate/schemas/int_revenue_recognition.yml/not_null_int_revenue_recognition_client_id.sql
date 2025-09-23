
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select client_id
from main_intermediate."int_revenue_recognition"
where client_id is null



  
  
      
    ) dbt_internal_test