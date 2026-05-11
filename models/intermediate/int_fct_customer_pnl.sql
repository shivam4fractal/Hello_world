with acdoca as (
  select * from {{ ref('stg_amer_nafpa__acdoca') }}
),
kpi_map as (
  select * from {{ source('amer_h_manual_mst', 't_nala_cstmr_pnl_kpi_mapping') }}
),
ska1 as (
  select * from {{ source('amer_h_saps4_am', 't_ska1') }}
),
material as (
  select * from {{ source('amer_dc_md', 't_dim_material') }}
),
company as (
  select * from {{ source('amer_dc_md', 't_dim_company_code') }}
),
country as (
  select * from {{ source('amer_dc_md', 't_dim_country') }}
)
select
  {{ farm_fingerprint([cal_sk]) }} as cal_sk,
  {{ farm_fingerprint([account_cust_pnl_sk]) }} as account_cust_pnl_sk,
  {{ farm_fingerprint([fi_org_sk]) }} as fi_org_sk,
  {{ farm_fingerprint([customer_sk]) }} as customer_sk,
  {{ farm_fingerprint([product_sk]) }} as product_sk,
  {{ farm_fingerprint([vendor_sk]) }} as vendor_sk,
  {{ farm_fingerprint([product_sold_sk]) }} as product_sold_sk,
  {{ farm_fingerprint([pnl_kpi_sk]) }} as pnl_kpi_sk,
  {{ farm_fingerprint([units_sk]) }} as units_sk,
  {{ farm_fingerprint([plant_sk]) }} as plant_sk,
  {{ farm_fingerprint([customer_salesarea_sk]) }} as customer_salesarea_sk,
  cast(kpi_value_base_uom as string) as kpi_value_base_uom,
  cast(kpi_value_cse as string) as kpi_value_cse,
  cast(kpi_value_lbs as string) as kpi_value_lbs,
  cast(kpi_value_kgs as string) as kpi_value_kgs,
  cast(glbl_curr_kpi_value as string) as glbl_curr_kpi_value,
  cast(lcl_curr_kpi_value as string) as lcl_curr_kpi_value,
  cast(txn_curr_kpi_value as string) as txn_curr_kpi_value
from acdoca