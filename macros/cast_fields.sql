{% macro cast_fields(field, type) %}
  coalesce(cast({{ field }} as {{ type }}), null)
{% endmacro %}