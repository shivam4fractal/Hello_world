with company as (
  select * from {{ source("amer_dc_md", "t_dim_company_code") }}
)
select
  cast(fi_org_sk as string) as fi_org_sk,
  cast(controlling_area as string) as controlling_area,
  cast(company_code_nk as string) as company_code_nk,
  cast(company_nm as string) as company_nm,
  cast(cost_center_nk as string) as cost_center_nk,
  cast(profit_center_nk as string) as profit_center_nk,
  cast(entity as string) as entity,
  cast(cluster_code_nk as string) as cluster_code_nk,
  cast(country_code_nk as string) as country_code_nk,
  cast(country_nm as string) as country_nm,
  cast(source_system as string) as source_system
from company