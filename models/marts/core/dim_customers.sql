{{
    config(
        materialized='table'
    )
}}
with customers as (
    select * from {{ ref('stg_sales_platform__customers') }}
),
customer_metrics as (
    select * from {{ ref('int_customers__metrics') }}
),
final as (
    select
        -- Primary Key
        c.customer_id,
        
        -- Customer Attributes
        c.first_name,
        c.last_name,
        c.first_name || ' ' || c.last_name as full_name,
        c.email,
        c.phone,


        
        -- Address
        c.address_line_1,
        c.address_line_2,
        c.city,
        c.state,
        c.postal_code,
        c.country,
        
        -- Customer Metrics
        coalesce(m.total_orders, 0) as total_orders,
        coalesce(m.completed_orders, 0) as completed_orders,
        coalesce(m.cancelled_orders, 0) as cancelled_orders,
        coalesce(m.lifetime_value, 0) as lifetime_value,
        coalesce(m.completed_order_value, 0) as completed_order_value,
        coalesce(m.avg_order_value, 0) as avg_order_value,
        m.first_order_date,
        m.last_order_date,
        coalesce(m.customer_tenure_days, 0) as customer_tenure_days,
        coalesce(m.total_paid, 0) as total_paid,
        coalesce(m.total_outstanding, 0) as total_outstanding,
        
        -- Customer Segmentation
        case
            when m.total_orders is null then 'prospect'
            when m.total_orders = 1 then 'one_time'
            when m.total_orders between 2 and 5 then 'repeat'
            when m.total_orders > 5 then 'loyal'
        end as customer_segment,
        
        case
            when m.lifetime_value >= 1000 then 'high_value'
            when m.lifetime_value >= 500 then 'medium_value'
            when m.lifetime_value > 0 then 'low_value'
            else 'no_value'
        end as value_segment,
        
        -- Metadata
        c.created_at,
        c.updated_at,
        c._loaded_at
        


    from customers c
    left join customer_metrics m on c.customer_id = m.customer_id
)
select * from final
