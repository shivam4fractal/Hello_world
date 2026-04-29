{% macro date_spine(start_date, end_date) %}
    with date_spine as (
        select
            dateadd(
                day,
                row_number() over (order by null) - 1,
                '{{ start_date }}':\:date
            ) as date_day
        from table(generator(rowcount => datediff(day, '{{ start_date }}':\:date, '{{ end_date }}':\:date) 
+ 1))
    )
    select * from date_spine
{% endmacro %}
