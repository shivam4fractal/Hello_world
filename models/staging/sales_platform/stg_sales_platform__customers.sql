with source as (
    select * from {{ source('sales_platform', 'customers') }}
),


renamed as (
    select
        -- Primary Key
        customer_id,
        
        -- Descriptive Fields
        first_name,
        last_name,
        email,
        phone,
        
        -- Address Fields
        address_line_1,
        address_line_2,
        city,
        state,
        postal_code,
        country,
        
        -- Metadata
        created_at,
        updated_at,
        _loaded_at
        
    from source
)
select * from renamed
