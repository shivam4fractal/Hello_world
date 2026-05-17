{% macro farm_fingerprint(fields) %}
  FARM_FINGERPRINT(CONCAT({% for f in fields %}COALESCE(CAST({{ f }} AS STRING), ''){% if not loop.last %}, '|', {% endif %}{% endfor %}))
{% endmacro %}