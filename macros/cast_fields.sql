{% macro cast_fields(model, fields) %}
SELECT
  {% for field in fields %}
    CAST({{ field.name }} AS {{ field.dtype }}) AS {{ field.name }}{% if not loop.last %},
  {% endif %}
  {% endfor %}
FROM {{ model }}
{% endmacro %}