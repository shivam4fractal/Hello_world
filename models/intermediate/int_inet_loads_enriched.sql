with base as (
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
  base.internal_order_id_nk,
  -- internal_load_id_nk
  base.internal_load_id_nk,
  -- costid_nk
  base.costid_nk,
  -- internal_orderdetail_id_nk
  base.internal_orderdetail_id_nk,
  -- to_bonus_time
  base.to_bonus_time,
  -- to_order_number
  base.to_order_number,
  -- to_load_number
  base.to_load_number,
  -- ld_load_name
  base.ld_load_name,
  -- means_of_transport
  base.means_of_transport,
  -- to_special_order_type
  base.to_special_order_type,
  -- to_act_pickup_date
  base.to_act_pickup_date,
  -- co_total_costs
  base.co_total_costs,
  -- co_cost_type
  base.co_cost_type,
  -- to_weight_unit
  base.to_weight_unit,
  -- to_gross_weight
  base.to_gross_weight,
  -- packagetype
  base.packagetype,
  -- to_consigner_city
  base.to_consigner_city,
  -- to_consigner_country
  base.to_consigner_country,
  -- lane_name
  base.lane_name,
  -- route_distance
  base.route_distance,
  -- to_purchase_order_number
  base.to_purchase_order_number,
  -- to_consignor_id
  base.to_consignor_id,
  -- totalpalletsactual
  base.totalpalletsactual,
  -- totalpalletsplaned
  base.totalpalletsplaned,
  -- to_status
  base.to_status,
  -- to_floor_pallets_actuals
  base.to_floor_pallets_actuals,
  -- to_floor_pallets_planned
  base.to_floor_pallets_planned,
  -- pickup_status
  base.pickup_status,
  -- to_reference_number
  base.to_reference_number,
  -- to_delivery_note_number
  base.to_delivery_note_number,
  -- to_recipient_city
  base.to_recipient_city,
  -- to_recipient_country
  base.to_recipient_country,
  -- to_recipient_id
  base.to_recipient_id,
  -- to_recipient_name
  base.to_recipient_name,
  -- to_recipient_zipcode
  base.to_recipient_zipcode,
  -- to_remarks
  base.to_remarks,
  -- transport_start_date
  base.transport_start_date,
  -- to_consigner_name
  base.to_consigner_name,
  -- to_pallet_places
  base.to_pallet_places,
  -- ld_transport_end_date
  base.ld_transport_end_date
from base
left join ship_load on base.shipment_id = ship_load.shipment_id
left join ship_cost on base.shipment_id = ship_cost.shipment_id
left join odr_dt on base.order_id = odr_dt.order_id
left join dim_vh on base.vehicle_id = dim_vh.vehicle_id
left join pick_up_del on base.pickup_id = pick_up_del.pickup_id
left join dim_consignor on base.consignor_id = dim_consignor.coordinator_id
left join dim_receiver on base.receiver_id = dim_receiver.coordinator_id