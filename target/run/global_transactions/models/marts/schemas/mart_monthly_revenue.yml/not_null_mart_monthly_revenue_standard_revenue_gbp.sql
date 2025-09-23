
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select standard_revenue_gbp
from main_marts."mart_monthly_revenue"
where standard_revenue_gbp is null



  
  
      
    ) dbt_internal_test