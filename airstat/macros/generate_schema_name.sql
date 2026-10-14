{% macro generate_schema_name(custom_schema_name, node) -%}
    {#- Use the custom schema as-is (e.g. BRONZE) instead of prefixing it with the target schema (e.g. DEV_BRONZE) -#}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
