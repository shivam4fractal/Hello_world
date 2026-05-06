{% macro cast_fields(field, type) %}
  case when {{ field }} is null then null else cast({{ field }} as {{ type }}) end
{% endmacro %}