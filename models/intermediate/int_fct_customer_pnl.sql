with acdoca as (
  select * from {{ ref('stg_amer_nafpa__acdoca') }}
),
kpi_map as (
  select * from {{ source('amer_h_manual_mst', 't_nala_cstmr_pnl_kpi_mapping') }}
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
  {{ farm_fingerprint([concat(To_date(extract(year from cast(amer_h_saps4_am.t_acdoca.budat as date;extract(month from cast(amer_h_saps4_am.t_acdoca.budat as date;'01']) }} as cal_sk,
  {{ farm_fingerprint([FARM_FINGERPRINT( CONCAT( amer_h_saps4_am.t_acdoca.ktopl; '|'; amer_h_saps4_am.t_acdoca.rbukrs; '|'; amer_h_saps4_am.t_acdoca.racct;  '|'; amer_h_saps4_am.t_ska1.bilkt;    '|'; amer_h_saps4_am.t_ska1.ktoks;    '|'; amer_h_saps4_am.t_ska1.gvtyp;    '|'; 'SAPS4_AM_NA']) }} as account_cust_pnl_sk,
  {{ farm_fingerprint([farm_fingerprint(CONCAT(amer_h_saps4_am.t_acdoca.prctr; '|';  amer_h_saps4_am.t_acdoca.rcntr;'|'; amer_h_saps4_am.t_acdoca.rbukrs ; '|'; amer_dc_md.t_dim_country.country_cd_nk ; '|' ; 'SAPS4_AM_NA']) }} as fi_org_sk,
  cast(customer_sk as string) as customer_sk,
  cast(product_sk as string) as product_sk,
  cast(vendor_sk as string) as vendor_sk,
  cast(product_sold_sk as string) as product_sold_sk,
  {{ farm_fingerprint([farm_fingerprint(concat(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.kpi_name;amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.cluster_code_nk; amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account;'SAPS4_AM_NA')
]) }} as pnl_kpi_sk,
  {{ farm_fingerprint([farm_fingerprint(concat(
amer_h_saps4_am.t_acdoca.rhcur;
amer_h_saps4_am.t_acdoca.rkcur;
amer_h_saps4_am.t_acdoca.rwcur;
amer_h_saps4_am.t_acdoca.runit;
'SAPS4_AM_NA'
]) }} as units_sk,
  cast(plant_sk as string) as plant_sk,
  {{ farm_fingerprint([farm_fingerprint(concat(amer_h_saps4_am.t_acdoca.matnr; amer_h_saps4_am.t_acdoca.vkorg;amer_h_saps4_am.t_acdoca.vtweg]) }} as customer_salesarea_sk,
  cast(kpi_value_base_uom as string) as kpi_value_base_uom,
  -- kpi_value_cse: "acdoca.msl * (c.denominator_conversion_base_units_measure_qt / c.numerator_conversion_base_units_measure_qt) as kpi_value_cse; from amer_h_saps4_am.t_acdoca.t_acdoca as a left join t_dim_material_uom  as c on a.matnr = c.material_cd_nk and c.alternate_uom_cd = ""CSE"" where c.alternate_uom_cd is not null",
  -- kpi_value_lbs: "acdoca.msl * (l.denominator_conversion_base_units_measure_qt / l.numerator_conversion_base_units_measure_qt) as kpi_value_cse; from amer_h_saps4_am.t_acdoca.t_acdoca as a left join t_dim_material_uom  as l on a.matnr = l.material_cd_nk and c.alternate_uom_cd = ""LB"" where l.alternate_uom_cd is not null",
  -- kpi_value_kgs: "acdoca.msl * (k.denominator_conversion_base_units_measure_qt / k.numerator_conversion_base_units_measure_qt) as kpi_value_cse; from amer_h_saps4_am.t_acdoca.t_acdoca as a left join t_dim_material_uom  as k on a.matnr = k.material_cd_nk and k.alternate_uom_cd = ""KG"" where k.alternate_uom_cd is not null",
  cast(glbl_curr_kpi_value as string) as glbl_curr_kpi_value,
  cast(lcl_curr_kpi_value as string) as lcl_curr_kpi_value,
  cast(txn_curr_kpi_value as string) as txn_curr_kpi_value
from acdoca
  -- add joins to kpi_map, material, company, country as per mapping logic