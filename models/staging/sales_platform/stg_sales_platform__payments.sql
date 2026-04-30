with source as (
    select * from {{ source('sales_platform', 'payments') }}
),
renamed as (
    select
        -- Primary Key
        payment_id,
        
        -- Foreign Keys
        order_id,
        
        -- Payment Details
        payment_method,
        payment_status,
        payment_amount,
        payment_date,
        
        -- Transaction Details
        transaction_id,


        processor,
        
        -- Table Metadata
        created_at,
        updated_at,
        _loaded_at
        
    from source
)
select * from renamed
