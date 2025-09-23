
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select recognised_transaction_count
from main_marts."mart_monthly_revenue"
where recognised_transaction_count is null



  
  
      
    ) dbt_internal_test