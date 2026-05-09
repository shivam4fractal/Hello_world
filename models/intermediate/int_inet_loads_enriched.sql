with ordr as (
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
  -- internal_order_id_nk: `dev-meu-analyt-lops-svc-28.meu_ds_lops.v_fct_shipment_order` as ordr table is driving table as ordr;  join this table with 
`dev-meu-analyt-lops-svc-28.meu_ds_lops.v_fct_shipment_cost`  as ship_cost on columns internal_order_id_nk from ordr table and internal_order_id from  ship_cost and there should be some filter condition view v_fct_shipment_cost on cloumns costtype will be Freight charges and Cancelled_Y_N column should be equal to N and rejected_Y_N column should be N and take the internal_order_id_nk from v_fct_shipment_order
  ordr.internal_order_id_nk as internal_order_id_nk,
  -- internal_load_id_nk: v_fct_shipment_order table is driving table;  join this table with 
`dev-meu-analyt-lops-svc-28.meu_ds_lops.v_fct_shipment_load` as ship_load  on columns internal_load_id from ordr table and take internal_load_id_nk from view v_fct_shipment_load
  ordr.internal_load_id_nk as internal_load_id_nk,
  -- costid_nk: use the Mapping / Reference / Calculation column defined for 
harmonized table name internal_order_id_nk and take the cost_id_nk 
from table v_fct_shipment_cost
  ordr.costid_nk as costid_nk,
  -- internal_orderdetail_id_nk:  v_fct_shipment_order table is driving table;  join this table with 
`dev-meu-analyt-lops-svc-28.meu_ds_lops.v_fct_shipment_orderdetail`as odr_dt on columns internal_order_id from view v_fct_shipment_orderdetail and take internal_orderdetail_id_nk  from view v_fct_shipment_order
  ordr.internal_orderdetail_id_nk as internal_orderdetail_id_nk,
  -- to_bonus_time: v_fct_shipment_order table is driving table; take bonustime column from  v_fct_shipment_order
  ordr.to_bonus_time as to_bonus_time,
  -- to_order_number: v_fct_shipment_order table is driving table; take order_number column from  v_fct_shipment_order
  ordr.to_order_number as to_order_number,
  -- to_load_number: v_fct_shipment_order table is driving table; take loadid column from  v_fct_shipment_load
  ordr.to_load_number as to_load_number,
  -- ld_load_name: take loadname column from  v_fct_shipment_load
  ordr.ld_load_name as ld_load_name,
  -- means_of_transport:  v_fct_shipment_order table is driving table;join `dev-meu-analyt-lops-svc-28.meu_ds_lops.v_dim_vehicle` as dim_vh table with v_fct_shipment_load on columns dim_vehicle_sk from v_dim_vehicle and vehicle_id_sk from ship_load respectively and take means_of_transport from view v_dim_vehicle 
  ordr.means_of_transport as means_of_transport,
  -- to_special_order_type: take specialordertype column from  v_fct_shipment_order
  ordr.to_special_order_type as to_special_order_type,
  -- to_act_pickup_date: check if transportstartdate from view v_fct_shipment_load is null then pick the value from requested_pickup_dt of view v_fct_shipment_order
  ordr.to_act_pickup_date as to_act_pickup_date,
  -- co_total_costs: take totalcosts column from  v_fct_shipment_cost as co_total_costs
  ordr.co_total_costs as co_total_costs,
  -- co_cost_type: take costtype column from  v_fct_shipment_cost as co_cost_type
  ordr.co_cost_type as co_cost_type,
  -- to_weight_unit: take weightunit column from  v_fct_shipment_orderdetail as to_weight_unit
  ordr.to_weight_unit as to_weight_unit,
  -- to_gross_weight: take grossweight column from v_fct_shipment_orderdetail as to_gross_weight
  ordr.to_gross_weight as to_gross_weight,
  -- packagetype: take packagetype column from v_fct_shipment_orderdetail view
  ordr.packagetype as packagetype,
  -- to_consigner_city: v_fct_shipment_order table is driving table; Join table v_fct_shipment_order with `dev-meu-analyt-lops-svc-28.meu_ds_lops.v_dim_transportation_coordinator`as dim_consignor
both the tables are joined on consignor_id_sk  and dim_transportation_coordinator_sk respectively
there are certain business logic to calculate the to_consigner_city. If cordinator_id_nk  values from dim_consigner are '2505575';'PL06';'PL95' then take Skarbimierz Gum
value from Dim table; If cordinator_id_nk  values from dim_consigner are ''PL07';'PL95a'' then takeSkarbimierz Choc; if both the value are not then then take coordinator_city
value from Dim table as to_consigner_city
  ordr.to_consigner_city as to_consigner_city,
  -- to_consigner_country: take coordinator_country column from dim_consignor as to_consigner_country
  ordr.to_consigner_country as to_consigner_country,
  -- lane_name: take lanename column from view v_fct_shipment_load
  ordr.lane_name as lane_name,
  -- route_distance: take routedistance column from  v_fct_shipment_load  as route_distance
  ordr.route_distance as route_distance,
  -- to_purchase_order_number: take purchaseordernumber column from  v_fct_shipment_order as to_purchase_order_number
  ordr.to_purchase_order_number as to_purchase_order_number,
  -- to_consignor_id: take coordinator_id_nk column from dim_consignor as to_consignor_id
  ordr.to_consignor_id as to_consignor_id,
  -- totalpalletsactual: take totalpalletsactual column from  v_fct_shipment_order
  ordr.totalpalletsactual as totalpalletsactual,
  -- totalpalletsplaned: take totalpalletsplaned column from  v_fct_shipment_order
  ordr.totalpalletsplaned as totalpalletsplaned,
  -- to_status: take statusdate_sk column from  v_fct_shipment_order as to_status
  ordr.to_status as to_status,
  -- to_floor_pallets_actuals: take floorpalletsactual column from  v_fct_shipment_load as to_floor_pallets_actuals
  ordr.to_floor_pallets_actuals as to_floor_pallets_actuals,
  -- to_floor_pallets_planned: take floorpalletsplaned column from  v_fct_shipment_load as to_floor_pallets_planned
  ordr.to_floor_pallets_planned as to_floor_pallets_planned,
  -- pickup_status:  v_fct_shipment_order table is driving table;  join this table with 
`dev-meu-analyt-lops-svc-28.meu_ds_lops.v_dim_pick_up_delivery`  as pick_up_del on columns pickup_id_sk  from v_fct_shipment_order and dim_pick_up_delivery_sk from pick_up_del repectively and take pick_up_delivery_id_nk from view v_dim_pick_up_delivery
  ordr.pickup_status as pickup_status,
  -- to_reference_number: take referencenumber column from  v_fct_shipment_order as to_reference_number
  ordr.to_reference_number as to_reference_number,
  -- to_delivery_note_number: take deliverynotenumber column from  v_fct_shipment_order as to_delivery_note_number
  ordr.to_delivery_note_number as to_delivery_note_number,
  -- to_recipient_city:  v_fct_shipment_order table is driving table;  join this table with 
`dev-meu-analyt-lops-svc-28.meu_ds_lops.v_dim_transportation_coordinator`  as dim_receiver on columns recipient_id_sk and dim_transportation_coordinator_sk repectively and take coordinator_city from view v_dim_transportation_coordinator  as dim_receiver
  ordr.to_recipient_city as to_recipient_city,
  -- to_recipient_country: take coordinator_country column from dim_receiver
  ordr.to_recipient_country as to_recipient_country,
  -- to_recipient_id: take coordinator_id_nk column from dim_receiver
  ordr.to_recipient_id as to_recipient_id,
  -- to_recipient_name: take coordinator_name_nk column from dim_receiver
  ordr.to_recipient_name as to_recipient_name,
  -- to_recipient_zipcode: take coordinator_zipcode column from dim_receiver
  ordr.to_recipient_zipcode as to_recipient_zipcode,
  -- to_remarks: take remarks column from  v_fct_shipment_order as to_remarks
  ordr.to_remarks as to_remarks,
  -- transport_start_date: take transportstartdate column from  v_fct_shipment_load as transport_start_date
  ordr.transport_start_date as transport_start_date,
  -- to_consigner_name: take coordinator_name_nk column from dim_consignor as to_consigner_name
  ordr.to_consigner_name as to_consigner_name,
  -- to_pallet_places: take palletplaces column from  v_fct_shipment_orderdetail as to_pallet_places
  ordr.to_pallet_places as to_pallet_places,
  -- ld_transport_end_date: take transportenddate column from  v_fct_shipment_load as ld_transport_end_date
  ordr.ld_transport_end_date as ld_transport_end_date
from ordr
left join ship_load on ordr.internal_order_id_nk = ship_load.internal_order_id_nk
left join ship_cost on ordr.internal_order_id_nk = ship_cost.internal_order_id_nk
left join odr_dt on ordr.internal_order_id_nk = odr_dt.internal_order_id_nk
left join dim_vh on ordr.vehicle_id = dim_vh.vehicle_id
left join pick_up_del on ordr.pickup_id = pick_up_del.pickup_id
left join dim_consignor on ordr.consignor_id = dim_consignor.coordinator_id
left join dim_receiver on ordr.receiver_id = dim_receiver.coordinator_id