
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select effective_fee_rate_percent
from main_marts."mart_monthly_revenue"
where effective_fee_rate_percent is null



  
  
      
    ) dbt_internal_test