
    
    

select
    transaction_id as unique_field,
    count(*) as n_records

from main_intermediate."int_revenue_recognition"
where transaction_id is not null
group by transaction_id
having count(*) > 1


