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
  {{ farm_fingerprint([concat(To_date(extract(year from cast(amer_h_saps4_am.t_acdoca.budat as date;extract(month from cast(amer_h_saps4_am.t_acdoca.budat as date;'01']) }} as cal_sk,
  {{ farm_fingerprint([FARM_FINGERPRINT(  amer_h_saps4_am.t_acdoca.ktopl; '|'; amer_h_saps4_am.t_acdoca.rbukrs; '|'; amer_h_saps4_am.t_acdoca.racct;  '|'; amer_h_saps4_am.t_ska1.bilkt;    '|'; amer_h_saps4_am.t_ska1.ktoks;    '|'; amer_h_saps4_am.t_ska1.gvtyp;    '|'; 'SAPS4_AM_NA']) }} as account_cust_pnl_sk,
  {{ farm_fingerprint([farm_fingerprint(amer_h_saps4_am.t_acdoca.prctr; '|';  amer_h_saps4_am.t_acdoca.rcntr;'|'; amer_h_saps4_am.t_acdoca.rbukrs ; '|'; amer_dc_md.t_dim_country.country_cd_nk ; '|' ; 'SAPS4_AM_NA']) }} as fi_org_sk,
  farm_fingerprint(amer_h_saps4_am.t_acdoca.kunnr) as customer_sk,
  farm_fingerprint(amer_h_saps4_am.t_acdoca.matnr)
union
farm_fingerprint(amer_h_saps4_am.t_acdoca.subbrand) as product_sk,
  farm_fingerprint(amer_h_saps4_am.t_acdoca.lifnr) as vendor_sk,
  farm_fingerprint(amer_h_saps4_am.t_acdoca.matnr_copa) as product_sold_sk,
  {{ farm_fingerprint([farm_fingerprint(concat(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.kpi_name;amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.cluster_code_nk; amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account;'SAPS4_AM_NA'
]) }} as pnl_kpi_sk,
  {{ farm_fingerprint([farm_fingerprint(concat(
amer_h_saps4_am.t_acdoca.rhcur;
amer_h_saps4_am.t_acdoca.rkcur;
amer_h_saps4_am.t_acdoca.rwcur;
amer_h_saps4_am.t_acdoca.runit;
'SAPS4_AM_NA'
]) }} as units_sk,
  farm_fingerprint(amer_h_saps4_am.t_acdoca.werks) as plant_sk,
  {{ farm_fingerprint([farm_fingerprint(concat(amer_h_saps4_am.t_acdoca.matnr; amer_h_saps4_am.t_acdoca.vkorg;amer_h_saps4_am.t_acdoca.vtweg]) }} as customer_salesarea_sk,
  amer_h_saps4_am.t_acdoca.msl as kpi_value_base_uom,
  -- join logic for kpi_value_cse,
  -- join logic for kpi_value_lbs,
  -- join logic for kpi_value_kgs,
  amer_h_saps4_am.t_acdoca.ksl as glbl_curr_kpi_value,
  amer_h_saps4_am.t_acdoca.hsl as lcl_curr_kpi_value,
  amer_h_saps4_am.t_acdoca.wsl as txn_curr_kpi_value
from acdoca
-- joins and logic as per mapping