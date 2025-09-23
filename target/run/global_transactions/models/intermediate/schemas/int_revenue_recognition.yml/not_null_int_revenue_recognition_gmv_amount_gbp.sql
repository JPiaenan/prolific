
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select gmv_amount_gbp
from main_intermediate."int_revenue_recognition"
where gmv_amount_gbp is null



  
  
      
    ) dbt_internal_test