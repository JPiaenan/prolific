
    select
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
    
  
    
    

select
    client_id || '-' || revenue_month as unique_field,
    count(*) as n_records

from main_marts."mart_monthly_revenue"
where client_id || '-' || revenue_month is not null
group by client_id || '-' || revenue_month
having count(*) > 1



  
  
      
    ) dbt_internal_test