select
*,

    -- Determine which fee margin to apply -  assumption: in the contract period, if threshold met, discounted fee applies, other wise standard (platform) fee applies
    case  when spend_threshold_met = 1 then discounted_fee_margin
        else platform_fee_margin end as applied_fee_margin,

    -- Calculate actual platform fee based on applied margin
    round(
        transaction_amount_gbp *
        case when spend_threshold_met = 1 then discounted_fee_margin
            else platform_fee_margin end, 2) as actual_platform_fee_gbp,

    -- Calculate fee savings from discount
    round(
        transaction_amount_gbp * (platform_fee_margin -
            case when spend_threshold_met = 1 then discounted_fee_margin
                else platform_fee_margin end ), 2 ) as fee_discount_savings_gbp,

    -- Flag transactions getting discount
    case
        when spend_threshold_met = 1 then 'discounted'
        when has_active_contract = 1 then 'standard_contract'
        else 'Standard_no_contract'
    end as fee_status

from int_client_contract_periods