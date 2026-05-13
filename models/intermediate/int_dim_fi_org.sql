with company_code as (
  select * from {{ source("amer_dc_md", "t_dim_company_code") }}
)
select
  FARM_FINGERPRINT(CONCAT(farm_fingerprint(CONCAT(amer_h_saps4_am.t_acdoca.prctr; '|';  amer_h_saps4_am.t_acdoca.rcntr;'|'; amer_h_saps4_am.t_acdoca.rbukrs ; '|'; amer_dc_md.t_dim_country.country_cd_nk ; '|' ; 'SAPS4_AM_NA')))) as fi_org_sk,
  amer_h_saps4_am.t_acdoca.kokrs as controlling_area,
  amer_h_saps4_am.t_acdoca.rbukrs as company_code_nk,
  amer_dc_md.t_dim_company_code.company_nm as company_nm,
  amer_h_saps4_am.t_acdoca.rcntr as cost_center_nk,
  amer_h_saps4_am.t_acdoca.prctr as profit_center_nk,
  select l5_node_id
join amer_h_saps4_am.t_acdoca.prctr = t_ref_profit_center_hierarchy.profit_center_nk and amer_h_saps4_am.t_acdoca.kokrs = t_ref_profit_center_hierarchy.controlling_area as entity,
  Hardcoded - NA as cluster_code_nk,
  select country_cd_nk from amer_dc_md.t_dim_country
join amer_dc_md.t_dim_company_code.country_code_nk = amer_dc_md.t_dim_coutry.country_code_nk
join amer_h_saps4_am.t_acdoca.rbukrs = amer_dc_md.t_dim_company_code.company_cd_nk  as country_code_nk,
  
select country_name_nm from amer_dc_md.t_dim_country
join amer_dc_md.t_dim_company_code.country_code_nk = amer_dc_md.t_dim_coutry.country_code_nk
join amer_h_saps4_am.t_acdoca.rbukrs = amer_dc_md.t_dim_company_code.company_cd_nk  as country_nm,
  SAPS4_AM_NA as source_system
from company_code