
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select original_currency
from main_intermediate."int_client_contract_periods"
where original_currency is null



  
  
      
    ) dbt_internal_test