{% macro get_payment_methods() %}
    {{ return(['credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash']) }}
{% endmacro %}
