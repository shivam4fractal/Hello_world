with acdoca as (
  select * from {{ ref("stg_amer_nafpa__acdoca") }}
)
select
  {{ farm_fingerprint(["cal_sk"]) }} as cal_sk,
  {{ farm_fingerprint(["account_cust_pnl_sk"]) }} as account_cust_pnl_sk,
  {{ farm_fingerprint(["fi_org_sk"]) }} as fi_org_sk,
  {{ farm_fingerprint(["customer_sk"]) }} as customer_sk,
  {{ farm_fingerprint(["product_sk"]) }} as product_sk,
  {{ farm_fingerprint(["vendor_sk"]) }} as vendor_sk,
  {{ farm_fingerprint(["product_sold_sk"]) }} as product_sold_sk,
  {{ farm_fingerprint(["pnl_kpi_sk"]) }} as pnl_kpi_sk,
  {{ farm_fingerprint(["units_sk"]) }} as units_sk,
  {{ farm_fingerprint(["plant_sk"]) }} as plant_sk,
  {{ farm_fingerprint(["customer_salesarea_sk"]) }} as customer_salesarea_sk,
  amer_h_saps4_am.t_acdoca.msl as kpi_value_base_uom,
  "acdoca.msl * (c.denominator_conversion_base_units_measure_qt / c.numerator_conversion_base_units_measure_qt) as kpi_value_cse; from amer_h_saps4_am.t_acdoca.t_acdoca as a left join t_dim_material_uom  as c on a.matnr = c.material_cd_nk and c.alternate_uom_cd = ""CSE"" where c.alternate_uom_cd is not null" as kpi_value_cse,
  "acdoca.msl * (l.denominator_conversion_base_units_measure_qt / l.numerator_conversion_base_units_measure_qt) as kpi_value_cse; from amer_h_saps4_am.t_acdoca.t_acdoca as a left join t_dim_material_uom  as l on a.matnr = l.material_cd_nk and c.alternate_uom_cd = ""LB"" where l.alternate_uom_cd is not null" as kpi_value_lbs,
  "acdoca.msl * (k.denominator_conversion_base_units_measure_qt / k.numerator_conversion_base_units_measure_qt) as kpi_value_cse; from amer_h_saps4_am.t_acdoca.t_acdoca as a left join t_dim_material_uom  as k on a.matnr = k.material_cd_nk and k.alternate_uom_cd = ""KG"" where k.alternate_uom_cd is not null" as kpi_value_kgs,
  amer_h_saps4_am.t_acdoca.ksl as glbl_curr_kpi_value,
  amer_h_saps4_am.t_acdoca.hsl as lcl_curr_kpi_value,
  amer_h_saps4_am.t_acdoca.wsl as txn_curr_kpi_value
from acdoca