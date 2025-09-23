
    
    

select
    client_id || '-' || revenue_month as unique_field,
    count(*) as n_records

from main_marts."mart_monthly_revenue"
where client_id || '-' || revenue_month is not null
group by client_id || '-' || revenue_month
having count(*) > 1


