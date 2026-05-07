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
  -- internal_order_id_nk
  ordr.internal_order_id_nk as internal_order_id_nk,
  -- internal_load_id_nk
  ordr.internal_load_id_nk as internal_load_id_nk,
  -- costid_nk
  ordr.costid_nk as costid_nk,
  -- internal_orderdetail_id_nk
  ordr.internal_orderdetail_id_nk as internal_orderdetail_id_nk,
  -- to_bonus_time
  ordr.to_bonus_time as to_bonus_time,
  -- to_order_number
  ordr.to_order_number as to_order_number,
  -- to_load_number
  ordr.to_load_number as to_load_number,
  -- ld_load_name
  ordr.ld_load_name as ld_load_name,
  -- means_of_transport
  ordr.means_of_transport as means_of_transport,
  -- to_special_order_type
  ordr.to_special_order_type as to_special_order_type,
  -- to_act_pickup_date
  ordr.to_act_pickup_date as to_act_pickup_date,
  -- co_total_costs
  ordr.co_total_costs as co_total_costs,
  -- co_cost_type
  ordr.co_cost_type as co_cost_type,
  -- to_weight_unit
  ordr.to_weight_unit as to_weight_unit,
  -- to_gross_weight
  ordr.to_gross_weight as to_gross_weight,
  -- packagetype
  ordr.packagetype as packagetype,
  -- to_consigner_city
  ordr.to_consigner_city as to_consigner_city,
  -- to_consigner_country
  ordr.to_consigner_country as to_consigner_country,
  -- lane_name
  ordr.lane_name as lane_name,
  -- route_distance
  ordr.route_distance as route_distance,
  -- to_purchase_order_number
  ordr.to_purchase_order_number as to_purchase_order_number,
  -- to_consignor_id
  ordr.to_consignor_id as to_consignor_id,
  -- totalpalletsactual
  ordr.totalpalletsactual as totalpalletsactual,
  -- totalpalletsplaned
  ordr.totalpalletsplaned as totalpalletsplaned,
  -- to_status
  ordr.to_status as to_status,
  -- to_floor_pallets_actuals
  ordr.to_floor_pallets_actuals as to_floor_pallets_actuals,
  -- to_floor_pallets_planned
  ordr.to_floor_pallets_planned as to_floor_pallets_planned,
  -- pickup_status
  ordr.pickup_status as pickup_status,
  -- to_reference_number
  ordr.to_reference_number as to_reference_number,
  -- to_delivery_note_number
  ordr.to_delivery_note_number as to_delivery_note_number,
  -- to_recipient_city
  ordr.to_recipient_city as to_recipient_city,
  -- to_recipient_country
  ordr.to_recipient_country as to_recipient_country,
  -- to_recipient_id
  ordr.to_recipient_id as to_recipient_id,
  -- to_recipient_name
  ordr.to_recipient_name as to_recipient_name,
  -- to_recipient_zipcode
  ordr.to_recipient_zipcode as to_recipient_zipcode,
  -- to_remarks
  ordr.to_remarks as to_remarks,
  -- transport_start_date
  ordr.transport_start_date as transport_start_date,
  -- to_consigner_name
  ordr.to_consigner_name as to_consigner_name,
  -- to_pallet_places
  ordr.to_pallet_places as to_pallet_places,
  -- ld_transport_end_date
  ordr.ld_transport_end_date as ld_transport_end_date
from ordr