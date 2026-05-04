with source as (
    select * from {{ source('sales_platform_src', 'orders') }}
),
renamed as (
    select
        -- Primary Key
        order_id,
        
        -- Foreign Keys
        customer_id,
        


        -- Order Details
        order_number,
        order_date,
        order_status,
        
        -- Financial Fields
        subtotal_amount,
        tax_amount,
        shipping_amount,
        discount_amount,
        total_amount,
        
        -- Metadata
        created_at,
        updated_at,
        _loaded_at
        
    from source
)
select * from renamed
