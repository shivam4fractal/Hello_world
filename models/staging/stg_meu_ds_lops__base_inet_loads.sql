with ordr as (
  select * from {{ source(meu_ds_lops, v_fct_shipment_order) }}
),
ship_load as (
  select * from {{ source(meu_ds_lops, v_fct_shipment_load) }}
),
ship_cost as (
  select * from {{ source(meu_ds_lops, v_fct_shipment_cost) }}
),
odr_dt as (
  select * from {{ source(meu_ds_lops, v_fct_shipment_orderdetail) }}
),
dim_vh as (
  select * from {{ source(meu_ds_lops, v_dim_vehicle) }}
),
pick_up_del as (
  select * from {{ source(meu_ds_lops, v_dim_pick_up_delivery) }}
),
dim_consignor as (
  select * from {{ source(meu_ds_lops, v_dim_transportation_coordinator) }}
),
dim_receiver as (
  select * from {{ source(meu_ds_lops, v_dim_transportation_coordinator) }}
)
select
  ordr.internal_order_id_nk,
  ordr.internal_load_id_nk,
  ordr.costid_nk,
  ordr.internal_orderdetail_id_nk,
  ordr.to_bonus_time,
  ordr.to_order_number,
  ordr.to_load_number,
  ordr.ld_load_name,
  ordr.means_of_transport,
  ordr.to_special_order_type,
  ordr.to_act_pickup_date,
  ordr.co_total_costs,
  ordr.co_cost_type,
  ordr.to_weight_unit,
  ordr.to_gross_weight,
  ordr.packagetype,
  ordr.to_consigner_city,
  ordr.to_consigner_country,
  ordr.lane_name,
  ordr.route_distance,
  ordr.to_purchase_order_number,
  ordr.to_consignor_id,
  ordr.totalpalletsactual,
  ordr.totalpalletsplaned,
  ordr.to_status,
  ordr.to_floor_pallets_actuals,
  ordr.to_floor_pallets_planned,
  ordr.pickup_status,
  ordr.to_reference_number,
  ordr.to_delivery_note_number,
  ordr.to_recipient_city,
  ordr.to_recipient_country,
  ordr.to_recipient_id,
  ordr.to_recipient_name,
  ordr.to_recipient_zipcode,
  ordr.to_remarks,
  ordr.transport_start_date,
  ordr.to_consigner_name,
  ordr.to_pallet_places,
  ordr.ld_transport_end_date
from ordr