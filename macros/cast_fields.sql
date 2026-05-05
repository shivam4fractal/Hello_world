{% macro cast_fields(field, type) %}
  case
    when type == "date" then cast({{ field }} as date)
    when type == "timestamp" then cast({{ field }} as timestamp)
    when type == "decimal" then cast({{ field }} as decimal(18,2))
    when type == "decimal4" then cast({{ field }} as decimal(18,4))
    when type == "bigint" then cast({{ field }} as bigint)
    when type == "string" then cast({{ field }} as string)
    else {{ field }}
  end
{% endmacro %}