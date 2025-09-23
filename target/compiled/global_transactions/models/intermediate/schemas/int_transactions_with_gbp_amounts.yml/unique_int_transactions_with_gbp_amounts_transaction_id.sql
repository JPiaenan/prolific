
    
    

select
    transaction_id as unique_field,
    count(*) as n_records

from main_intermediate."int_transactions_with_gbp_amounts"
where transaction_id is not null
group by transaction_id
having count(*) > 1


