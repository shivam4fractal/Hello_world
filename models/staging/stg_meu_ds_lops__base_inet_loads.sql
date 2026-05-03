-- Staging model for BASE_INET_LOADS_DATASET from meu_ds_lops
with base_inet_loads as (
    select
        cast(`internal_order_id_nk` as int ) as `internal_order_id_nk`,
        cast(`internal_load_id_nk` as int ) as `internal_load_id_nk`,
        cast(`costid_nk` as int ) as `costid_nk`
    from {{ source("meu_ds_lops", "BASE_INET_LOADS_DATASET") }}
)
select * from base_inet_loads
