
  
    
    
    create  table main_intermediate."int_transactions_with_fees"
    as
        

with contract_data as (
    select * from main_intermediate."int_client_contract_periods"
)

select 
    transaction_id,
    client_id,
    transaction_amount,
    transaction_type,
    transaction_date,
    platform_fee_margin as standard_fee_margin,
    original_currency,
    linked_transaction_id,
    exchange_rate_to_gbp,
    transaction_amount_gbp,
    contract_start_date,
    contract_end_date,
    spend_threshold,
    discounted_fee_margin,
    has_active_contract,
    cumulative_spend_in_contract,
    spend_threshold_met,

    -- Determine which fee margin to apply -  assumption: in the contract period, if threshold met, discounted fee applies, other wise standard (platform) fee applies
    case 
        when spend_threshold_met = 1 then discounted_fee_margin
        else platform_fee_margin
    end as applied_fee_margin,
    
    -- Calculate actual platform fee based on applied margin
    round(
        transaction_amount_gbp * 
        case 
            when spend_threshold_met = 1 then discounted_fee_margin
            else platform_fee_margin
        end, 
        2
    ) as actual_platform_fee_gbp,
    
    -- Calculate fee savings from discount
    round(
        transaction_amount_gbp * (platform_fee_margin - 
            case 
                when spend_threshold_met = 1 then discounted_fee_margin
                else platform_fee_margin
            end
        ), 
        2
    ) as fee_discount_savings_gbp,
    
    -- Flag transactions getting discount
    case 
        when spend_threshold_met = 1 then 'Discounted'
        when has_active_contract = 1 then 'Standard (Contract Active)'
        else 'Standard (No Contract)'
    end as fee_status
    
from contract_data

  