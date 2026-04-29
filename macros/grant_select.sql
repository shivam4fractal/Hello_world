{% macro grant_select(role, schema=target.schema) %}
    {% set sql %}


        grant select on all tables in schema {{ schema }} to role {{ role }};
        grant select on all views in schema {{ schema }} to role {{ role }};
    {% endset %}
    
    {% do run_query(sql) %}
    {% do log("Granted SELECT on " ~ schema ~ " to " ~ role, info=True) %}
{% endmacro %}
