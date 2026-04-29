{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='fail'
    )
}}
with orders_enriched as (
    select * from {{ ref('int_orders__enriched') }}
)
select
    -- Primary Key
    order_id,
    
    -- Foreign Keys
    customer_id,
    
    -- Order Attributes
    order_number,
    order_date,
    order_status,
    
    -- Financial Metrics
    subtotal_amount,
    tax_amount,
    shipping_amount,
    discount_amount,
    total_amount,
    
    -- Payment Metrics


    payment_count,
    total_paid_amount,
    outstanding_balance,
    payment_status_derived,
    last_payment_date,
    payment_methods_used,
    
    -- Metadata
    created_at,
    updated_at,
    _loaded_at
from orders_enriched
{% if is_incremental() %}
    where _loaded_at > (select max(_loaded_at) from {{ this }})
{% endif %}
