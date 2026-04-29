{{
    config(
        materialized='ephemeral'
    )
}}
with orders as (
    select * from {{ ref('stg_sales_platform__orders') }}
),
customers as (
    select * from {{ ref('stg_sales_platform__customers') }}
),
payments as (
    select * from {{ ref('stg_sales_platform__payments') }}
),
payment_aggregates as (
    select
        order_id,
        count(*) as payment_count,
        sum(payment_amount) as total_paid_amount,
        max(payment_date) as last_payment_date,
        listagg(distinct payment_method, ', ') within group (order by payment_method) as payment_methods_used
    from payments
    where payment_status = 'completed'
    group by order_id


),
enriched as (
    select
        -- Order identifiers
        o.order_id,
        o.order_number,
        o.order_date,
        o.order_status,
        
        -- Customer information
        o.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.city,
        c.state,
        c.country,
        
        -- Order financials
        o.subtotal_amount,
        o.tax_amount,
        o.shipping_amount,
        o.discount_amount,
        o.total_amount,
        
        -- Payment information
        coalesce(p.payment_count, 0) as payment_count,
        coalesce(p.total_paid_amount, 0) as total_paid_amount,
        p.last_payment_date,
        p.payment_methods_used,
        
        -- Derived fields
        case
            when coalesce(p.total_paid_amount, 0) >= o.total_amount then 'fully_paid'
            when coalesce(p.total_paid_amount, 0) > 0 then 'partially_paid'
            else 'unpaid'
        end as payment_status_derived,
        
        o.total_amount - coalesce(p.total_paid_amount, 0) as outstanding_balance,
        
        -- Metadata


        o.created_at,
        o.updated_at,
        o._loaded_at
        
    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join payment_aggregates p on o.order_id = p.order_id
)
select * from enriched
