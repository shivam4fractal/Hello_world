{% macro farm_fingerprint(fields) %}
  farm_fingerprint(concat({% for f in fields %}coalesce(cast({{ f }} as string), ){% if not loop.last %}, |, {% endif %}{% endfor %}))
{% endmacro %}