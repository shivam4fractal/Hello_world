{% macro farm_fingerprint(fields) %}
  md5(concat({% for f in fields %}coalesce(cast({{ f }} as string), ''){% if not loop.last %}, '|', {% endif %}{% endfor %}))
{% endmacro %}