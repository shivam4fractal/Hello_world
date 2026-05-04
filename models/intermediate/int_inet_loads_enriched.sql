-- Intermediate model for enriched BASE_INET_LOADS_DATASET
with base as (
    select * from {{ ref("stg_meu_ds_lops__base_inet_loads") }}
)
select
    `internal_order_id_nk`, -- v_fct_shipment_order table is driving table,  join this table with 
,
    `internal_load_id_nk`, -- v_fct_shipment_order table is driving table,  join this table with 
,
    `costid_nk`, -- use the Mapping / Reference / Calculation column defined for 

from base
