(ADVANCED)
{%- macro apply_data_quality_rules(model_name, rules_dict) -%}
    {%- set ns = namespace(conditions=[]) -%}
    
    {%- for rule_name, rule_config in rules_dict.items() -%}
        {%- if rule_config.type == 'not_null' -%}
            {%- set condition -%}
                {{ rule_config.column }} is not null
            {%- endset -%}
            {%- set ns.conditions = ns.conditions + [condition] -%}
        
        {%- elif rule_config.type == 'range' -%}
            {%- set condition -%}
                {{ rule_config.column }} between {{ rule_config.min }} and {{ rule_config.max }}
            {%- endset -%}
            {%- set ns.conditions = ns.conditions + [condition] -%}
        
        {%- elif rule_config.type == 'accepted_values' -%}
            {%- set condition -%}
                {{ rule_config.column }} in (
                    {%- for value in rule_config.values -%}
                        '{{ value }}'{% if not loop.last %}, {% endif %}
                    {%- endfor -%}
                )
            {%- endset -%}
            {%- set ns.conditions = ns.conditions + [condition] -%}
        
        {%- elif rule_config.type == 'custom_sql' -%}
            {%- set ns.conditions = ns.conditions + [rule_config.expression] -%}
        {%- endif -%}
    {%- endfor -%}
    
    {%- if ns.conditions | length > 0 -%}
        where


            {%- for condition in ns.conditions %}
                ({{ condition }})
                {%- if not loop.last %} and {% endif -%}
            {%- endfor %}
    {%- endif -%}
{%- endmacro -%}
