{% macro cast_fields(field, type) %}
  cast({{ field }} as {{ type }})
{% endmacro %}