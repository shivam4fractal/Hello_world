{% macro cast_fields(field_map) %}
  {% for field, dtype in field_map.items() %}
    cast({{ field }} as {{ dtype }}) as {{ field }}{% if not loop.last %}, {% endif %}
  {% endfor %}
{% endmacro %}