{{
    config(
        materialized='incremental',
        unique_key='date_day',
        on_schema_change='fail'
    )
}}
with orders as (
    select * from {{ ref('fct_orders') }}
),
daily_aggregates as (
    select
        date_trunc('day', order_date) as date_day,
        
        -- Order counts
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as unique_customers,
        count(distinct case when order_status = 'completed' then order_id end) as completed_orders,
        count(distinct case when order_status = 'cancelled' then order_id end) as cancelled_orders,
        
        -- Revenue metrics
        sum(total_amount) as total_revenue,
        sum(subtotal_amount) as total_subtotal,
        sum(tax_amount) as total_tax,
        sum(shipping_amount) as total_shipping,
        sum(discount_amount) as total_discounts,
        
        -- Payment metrics
        sum(total_paid_amount) as total_collected,
        sum(outstanding_balance) as total_outstanding,
        
        -- Averages
        avg(total_amount) as avg_order_value,
        avg(payment_count) as avg_payments_per_order


        
    from orders
    group by date_trunc('day', order_date)
)
select * from daily_aggregates
{% if is_incremental() %}
    where date_day > (select max(date_day) from {{ this }})
{% endif %}
