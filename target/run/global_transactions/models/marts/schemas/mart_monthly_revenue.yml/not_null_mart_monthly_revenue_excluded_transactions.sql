
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select excluded_transactions
from main_marts."mart_monthly_revenue"
where excluded_transactions is null



  
  
      
    ) dbt_internal_test