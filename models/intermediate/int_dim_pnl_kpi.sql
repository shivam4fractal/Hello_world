with kpi_map as (
  select * from {{ source('amer_h_manual_mst', 't_nala_cstmr_pnl_kpi_mapping') }}
)
select
  cast(pnl_kpi_sk as string) as pnl_kpi_sk,
  cast(kpi_level_1 as string) as kpi_level_1,
  cast(kpi_level_2 as string) as kpi_level_2,
  cast(kpi_level_3 as string) as kpi_level_3,
  cast(kpi_level_4 as string) as kpi_level_4,
  cast(kpi_level_5 as string) as kpi_level_5,
  cast(kpi_level_6 as string) as kpi_level_6,
  cast(kpi_level_7 as string) as kpi_level_7,
  cast(kpi_level_8 as string) as kpi_level_8,
  cast(kpi_name as string) as kpi_name,
  cast(gl_account_nb_nk as string) as gl_account_nb_nk,
  cast(cluster_code_nk as string) as cluster_code_nk,
  cast(sign_multiplier as string) as sign_multiplier,
  cast(additive_flg as string) as additive_flg,
  cast(kpi_formula as string) as kpi_formula,
  cast(source_system as string) as source_system
from kpi_map