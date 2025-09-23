{{
  config(
    materialized='table'
  )
}}

with revenue_data as (
    select * from {{ ref('int_revenue_recognition') }}
)

select 
    client_id,
    strftime('%Y-%m', transaction_date) as revenue_month,
    
    -- Revenue metrics
    round(sum(case when include_in_revenue = 1 then revenue_amount_gbp else 0 end), 2) as total_revenue_gbp,
    count(case when include_in_revenue = 1 then transaction_id end) as recognised_transaction_count,
    
    -- GMV metrics  
    round(sum(gmv_amount_gbp), 2) as total_gmv_gbp,
    round(sum(case when transaction_type = 'payment' then transaction_amount_gbp else 0 end), 2) as payment_volume_gbp,
    round(sum(case when transaction_type = 'refund' then transaction_amount_gbp else 0 end), 2) as refund_volume_gbp,
    round(sum(case when transaction_type = 'chargeback' then transaction_amount_gbp else 0 end), 2) as chargeback_volume_gbp,
    round(sum(case when transaction_type = 'fraud' then transaction_amount_gbp else 0 end), 2) as fraud_volume_gbp,
    
    -- Contract and spend tracking
    max(spend_threshold) as monthly_spend_threshold,
    round(max(cumulative_spend_in_contract), 2) as max_cumulative_spend,
    max(case when spend_threshold_met = 1 then 1 else 0 end) as threshold_achieved_in_month,
    
    -- Discount application metrics
    round(sum(fee_discount_savings_gbp), 2) as total_fee_savings_gbp,
    round(sum(case when fee_status = 'Discounted' then revenue_amount_gbp else 0 end), 2) as discounted_revenue_gbp,
    round(sum(case when fee_status like 'Standard%' then revenue_amount_gbp else 0 end), 2) as standard_revenue_gbp,
    
    -- Transaction counts by type
    count(case when transaction_type = 'payment' then 1 end) as payment_count,
    count(case when transaction_type = 'refund' then 1 end) as refund_count,
    count(case when transaction_type = 'chargeback' then 1 end) as chargeback_count,
    count(case when transaction_type = 'fraud' then 1 end) as fraud_count,
    
    -- Revenue recognition status summary
    count(case when revenue_recognition_status like 'Recognized%' then 1 end) as recognised_transactions,
    count(case when revenue_recognition_status like 'Pending%' then 1 end) as pending_transactions,
    count(case when revenue_recognition_status like 'Excluded%' then 1 end) as excluded_transactions,
    
    -- Contract status for the month
    case 
        when max(has_active_contract) = 1 then 'Active Contract'
        else 'No Contract'
    end as contract_status,
    
    -- Discount status summary
    case 
        when max(case when spend_threshold_met = 1 then 1 else 0 end) = 1 then 'Discount Applied'
        when max(has_active_contract) = 1 then 'Contract Active - Threshold Not Met'
        else 'No Contract'
    end as discount_application_status,
    
    -- Performance metrics
    round(
        case 
            when sum(case when transaction_type = 'payment' then transaction_amount_gbp else 0 end) > 0
            then (sum(case when include_in_revenue = 1 then revenue_amount_gbp else 0 end) / 
                  sum(case when transaction_type = 'payment' then transaction_amount_gbp else 0 end)) * 100
            else 0
        end, 
        2
    ) as effective_fee_rate_percent
    
from revenue_data
group by 
    client_id, 
    strftime('%Y-%m', transaction_date)
order by 
    client_id, 
    revenue_month
