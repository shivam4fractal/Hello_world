-- Mart model for harmonized BASE_INET_LOADS_DATASET
select * from {{ ref("int_inet_loads_enriched") }}
