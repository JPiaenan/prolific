
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    



select transaction_id
from main_intermediate."int_transactions_with_gbp_amounts"
where transaction_id is null



  
  
      
    ) dbt_internal_test