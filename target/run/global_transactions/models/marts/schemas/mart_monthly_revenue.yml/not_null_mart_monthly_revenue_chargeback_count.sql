
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select chargeback_count
from main_marts."mart_monthly_revenue"
where chargeback_count is null



  
  
      
    ) dbt_internal_test