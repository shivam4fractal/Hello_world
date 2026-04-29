{{
    config(
        materialized='ephemeral'
    )
}}
with orders as (
    select * from {{ ref('int_orders__enriched') }}
),
customer_metrics as (
    select
        customer_id,
        
        -- Order metrics
        count(distinct order_id) as total_orders,
        count(distinct case when order_status = 'completed' then order_id end) as completed_orders,
        count(distinct case when order_status = 'cancelled' then order_id end) as cancelled_orders,
        
        -- Financial metrics
        sum(total_amount) as lifetime_value,
        sum(case when order_status = 'completed' then total_amount else 0 end) as completed_order_value,
        avg(total_amount) as avg_order_value,
        
        -- Temporal metrics
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        datediff(day, min(order_date), max(order_date)) as customer_tenure_days,
        
        -- Payment metrics


        sum(total_paid_amount) as total_paid,
        sum(outstanding_balance) as total_outstanding
        
    from orders
    group by customer_id
)
select * from customer_metrics
