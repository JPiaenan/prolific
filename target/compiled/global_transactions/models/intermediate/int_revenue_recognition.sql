

with transactions_with_fees as (
    select * from main_intermediate."int_transactions_with_fees"
),

transaction_resolutions as (
    select * from main_staging."stg_transaction_resolutions"
)

select 
    t.transaction_id,
    t.client_id,
    t.transaction_amount,
    t.transaction_type,
    t.transaction_date,
    t.original_currency,
    t.linked_transaction_id,
    t.exchange_rate_to_gbp,
    t.transaction_amount_gbp,
    t.actual_platform_fee_gbp,
    t.fee_status,
    
    -- Add resolution data for chargebacks
    tr.resolution_status,
    tr.resolution_date,
    
    -- Apply revenue recognition rules
    case 
        when t.transaction_type = 'fraud' then 0
        when t.transaction_type = 'chargeback' and (tr.resolution_status != 'resolved' or tr.resolution_status is null) then 0
        when t.transaction_type = 'payment' then 1
        when t.transaction_type = 'refund' then 1
        when t.transaction_type = 'chargeback' and tr.resolution_status = 'resolved' then 1
        else 0
    end as include_in_revenue,
    
    -- Calculate revenue amounts based on transaction type
    case 
        when t.transaction_type = 'fraud' then 0
        when t.transaction_type = 'chargeback' and (tr.resolution_status != 'resolved' or tr.resolution_status is null) then 0
        when t.transaction_type = 'payment' then t.actual_platform_fee_gbp
        when t.transaction_type = 'refund' then -t.actual_platform_fee_gbp
        when t.transaction_type = 'chargeback' and tr.resolution_status = 'resolved' then t.actual_platform_fee_gbp
        else 0
    end as revenue_amount_gbp,
    
    -- Calculate GMV (Gross Merchandise Value) - transaction amounts excluding fraud
    case 
        when t.transaction_type = 'fraud' then 0
        when t.transaction_type = 'payment' then t.transaction_amount_gbp
        when t.transaction_type = 'refund' then -t.transaction_amount_gbp
        when t.transaction_type = 'chargeback' then -t.transaction_amount_gbp
        else 0
    end as gmv_amount_gbp,
    
    -- Revenue recognition status
    case 
        when t.transaction_type = 'fraud' then 'Excluded - Fraud'
        when t.transaction_type = 'chargeback' and tr.resolution_status is null then 'Pending - Chargeback Unresolved'
        when t.transaction_type = 'chargeback' and tr.resolution_status = 'pending' then 'Pending - Chargeback Unresolved'
        when t.transaction_type = 'chargeback' and tr.resolution_status = 'disputed' then 'Pending - Chargeback Disputed'
        when t.transaction_type = 'chargeback' and tr.resolution_status = 'resolved' then 'Recognized - Chargeback Resolved'
        when t.transaction_type = 'payment' then 'Recognized - Payment'
        when t.transaction_type = 'refund' then 'Recognized - Refund'
        else 'Unknown'
    end as revenue_recognition_status
    
from transactions_with_fees t
left join transaction_resolutions tr 
    on t.transaction_id = tr.transaction_id