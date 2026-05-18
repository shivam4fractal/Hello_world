with company_code as (
  select * from {{ source("amer_dc_md", "t_dim_company_code") }}
),
joined as (
  -- Add mapping logic here
  select
    FARM_FINGERPRINT(CONCAT(farm_fingerprint(CONCAT(amer_h_saps4_am.t_acdoca.prctr; '|';  amer_h_saps4_am.t_acdoca.rcntr;'|'; amer_h_saps4_am.t_acdoca.rbukrs ; '|'; amer_dc_md.t_dim_country.country_cd_nk ; '|' ; 'SAPS4_AM_NA')))) as fi_org_sk,
    cast(amer_h_saps4_am.t_acdoca.kokrs as string) as controlling_area,
    cast(amer_h_saps4_am.t_acdoca.rbukrs as string) as company_code_nk,
    cast(amer_dc_md.t_dim_company_code.company_nm as string) as company_nm,
    cast(amer_h_saps4_am.t_acdoca.rcntr as string) as cost_center_nk,
    cast(amer_h_saps4_am.t_acdoca.prctr as string) as profit_center_nk,
    cast(select l5_node_idjoin amer_h_saps4_am.t_acdoca.prctr = t_ref_profit_center_hierarchy.profit_center_nk and amer_h_saps4_am.t_acdoca.kokrs = t_ref_profit_center_hierarchy.controlling_area as string) as entity,
    cast(Hardcoded - NA as string) as cluster_code_nk,
    cast(select country_cd_nk from amer_dc_md.t_dim_countryjoin amer_dc_md.t_dim_company_code.country_code_nk = amer_dc_md.t_dim_coutry.country_code_nkjoin amer_h_saps4_am.t_acdoca.rbukrs = amer_dc_md.t_dim_company_code.company_cd_nk  as string) as country_code_nk,
    cast(select country_name_nm from amer_dc_md.t_dim_countryjoin amer_dc_md.t_dim_company_code.country_code_nk = amer_dc_md.t_dim_coutry.country_code_nkjoin amer_h_saps4_am.t_acdoca.rbukrs = amer_dc_md.t_dim_company_code.company_cd_nk  as string) as country_nm,
    cast(SAPS4_AM_NA as string) as source_system
  from company_code
  -- Add joins as per mapping logic
)
select
  fi_org_sk,
  controlling_area,
  company_code_nk,
  company_nm,
  cost_center_nk,
  profit_center_nk,
  entity,
  cluster_code_nk,
  country_code_nk,
  country_nm,
  source_system
from joined