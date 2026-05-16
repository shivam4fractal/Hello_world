with source as (
  select
    cal_sk as cal_sk,
    account_cust_pnl_sk as account_cust_pnl_sk,
    fi_org_sk as fi_org_sk,
    customer_sk as customer_sk,
    product_sk as product_sk,
    vendor_sk as vendor_sk,
    product_sold_sk as product_sold_sk,
    pnl_kpi_sk as pnl_kpi_sk,
    units_sk as units_sk,
    plant_sk as plant_sk,
    customer_salesarea_sk as customer_salesarea_sk,
    kpi_value_base_uom as kpi_value_base_uom,
    kpi_value_cse as kpi_value_cse,
    kpi_value_lbs as kpi_value_lbs,
    kpi_value_kgs as kpi_value_kgs,
    glbl_curr_kpi_value as glbl_curr_kpi_value,
    lcl_curr_kpi_value as lcl_curr_kpi_value,
    txn_curr_kpi_value as txn_curr_kpi_value
  from {{ source('amer_h_saps4_am', 't_acdoca') }}
)
select * from source