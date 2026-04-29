{% macro calculate_customer_ltv(
    orders_table,
    customer_id_column='customer_id',
    order_amount_column='total_amount',
    order_status_column='order_status',
    completed_status='completed'
) %}
    sum(
        case
            when {{ order_status_column }} = '{{ completed_status }}'
            then {{ order_amount_column }}
            else 0
        end
    ) as lifetime_value
{% endmacro %}
