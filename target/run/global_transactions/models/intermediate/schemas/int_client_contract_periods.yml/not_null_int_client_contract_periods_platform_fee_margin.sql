
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select platform_fee_margin
from main_intermediate."int_client_contract_periods"
where platform_fee_margin is null



  
  
      
    ) dbt_internal_test