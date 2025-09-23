with source as (
    select * from main."transaction_resolutions"
),

src_transaction_resolutions as (
    select
        transaction_id,
        resolution_status,
        case 
            when resolution_date is not null and resolution_date != ''
            then date(resolution_date, 'DD/MM/YYYY')
            else null
        end as resolution_date
        
    from source
)

select * from src_transaction_resolutions