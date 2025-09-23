
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select actual_platform_fee_gbp
from main_intermediate."int_transactions_with_fees"
where actual_platform_fee_gbp is null



  
  
      
    ) dbt_internal_test