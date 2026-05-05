with stg as (
  select * from {{ ref(stg_meu_ds_lops__base_inet_loads) }}
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
  stg.internal_order_id_nk as internal_order_id_nk,
  -- internal_load_id_nk
  stg.internal_load_id_nk as internal_load_id_nk,
  -- costid_nk
  stg.costid_nk as costid_nk,
  -- internal_orderdetail_id_nk
  stg.internal_orderdetail_id_nk as internal_orderdetail_id_nk,
  -- to_bonus_time
  stg.to_bonus_time as to_bonus_time,
  -- to_order_number
  stg.to_order_number as to_order_number,
  -- to_load_number
  stg.to_load_number as to_load_number,
  -- ld_load_name
  stg.ld_load_name as ld_load_name,
  -- means_of_transport
  stg.means_of_transport as means_of_transport,
  -- to_special_order_type
  stg.to_special_order_type as to_special_order_type,
  -- to_act_pickup_date
  stg.to_act_pickup_date as to_act_pickup_date,
  -- co_total_costs
  stg.co_total_costs as co_total_costs,
  -- co_cost_type
  stg.co_cost_type as co_cost_type,
  -- to_weight_unit
  stg.to_weight_unit as to_weight_unit,
  -- to_gross_weight
  stg.to_gross_weight as to_gross_weight,
  -- packagetype
  stg.packagetype as packagetype,
  -- to_consigner_city
  stg.to_consigner_city as to_consigner_city,
  -- to_consigner_country
  stg.to_consigner_country as to_consigner_country,
  -- lane_name
  stg.lane_name as lane_name,
  -- route_distance
  stg.route_distance as route_distance,
  -- to_purchase_order_number
  stg.to_purchase_order_number as to_purchase_order_number,
  -- to_consignor_id
  stg.to_consignor_id as to_consignor_id,
  -- totalpalletsactual
  stg.totalpalletsactual as totalpalletsactual,
  -- totalpalletsplaned
  stg.totalpalletsplaned as totalpalletsplaned,
  -- to_status
  stg.to_status as to_status,
  -- to_floor_pallets_actuals
  stg.to_floor_pallets_actuals as to_floor_pallets_actuals,
  -- to_floor_pallets_planned
  stg.to_floor_pallets_planned as to_floor_pallets_planned,
  -- pickup_status
  stg.pickup_status as pickup_status,
  -- to_reference_number
  stg.to_reference_number as to_reference_number,
  -- to_delivery_note_number
  stg.to_delivery_note_number as to_delivery_note_number,
  -- to_recipient_city
  stg.to_recipient_city as to_recipient_city,
  -- to_recipient_country
  stg.to_recipient_country as to_recipient_country,
  -- to_recipient_id
  stg.to_recipient_id as to_recipient_id,
  -- to_recipient_name
  stg.to_recipient_name as to_recipient_name,
  -- to_recipient_zipcode
  stg.to_recipient_zipcode as to_recipient_zipcode,
  -- to_remarks
  stg.to_remarks as to_remarks,
  -- transport_start_date
  stg.transport_start_date as transport_start_date,
  -- to_consigner_name
  stg.to_consigner_name as to_consigner_name,
  -- to_pallet_places
  stg.to_pallet_places as to_pallet_places,
  -- ld_transport_end_date
  stg.ld_transport_end_date as ld_transport_end_date
from stg
left join ship_load on stg.internal_order_id_nk = ship_load.internal_order_id_nk
left join ship_cost on stg.internal_order_id_nk = ship_cost.internal_order_id_nk
left join odr_dt on stg.internal_order_id_nk = odr_dt.internal_order_id_nk
left join dim_vh on stg.vehicle_id = dim_vh.vehicle_id
left join pick_up_del on stg.pickup_id = pick_up_del.pickup_id
left join dim_consignor on stg.consignor_id = dim_consignor.coordinator_id
left join dim_receiver on stg.receiver_id = dim_receiver.coordinator_id