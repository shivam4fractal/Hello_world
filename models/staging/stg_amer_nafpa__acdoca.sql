with source as (
  select * from {{ source('amer_h_saps4_am', 't_acdoca') }}
)
select
  cast(cal_sk as string) as cal_sk,
  cast(account_cust_pnl_sk as string) as account_cust_pnl_sk,
  cast(fi_org_sk as string) as fi_org_sk,
  cast(customer_sk as string) as customer_sk,
  cast(product_sk as string) as product_sk,
  cast(vendor_sk as string) as vendor_sk,
  cast(product_sold_sk as string) as product_sold_sk,
  cast(pnl_kpi_sk as string) as pnl_kpi_sk,
  cast(units_sk as string) as units_sk,
  cast(plant_sk as string) as plant_sk,
  cast(customer_salesarea_sk as string) as customer_salesarea_sk,
  cast(kpi_value_base_uom as string) as kpi_value_base_uom,
  cast(kpi_value_cse as string) as kpi_value_cse,
  cast(kpi_value_lbs as string) as kpi_value_lbs,
  cast(kpi_value_kgs as string) as kpi_value_kgs,
  cast(glbl_curr_kpi_value as string) as glbl_curr_kpi_value,
  cast(lcl_curr_kpi_value as string) as lcl_curr_kpi_value,
  cast(txn_curr_kpi_value as string) as txn_curr_kpi_value
from source