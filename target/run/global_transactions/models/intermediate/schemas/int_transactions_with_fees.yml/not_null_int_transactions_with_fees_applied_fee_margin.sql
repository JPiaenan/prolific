
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select applied_fee_margin
from main_intermediate."int_transactions_with_fees"
where applied_fee_margin is null



  
  
      
    ) dbt_internal_test