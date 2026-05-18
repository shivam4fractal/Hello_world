with kpi as (
  select * from {{ source("amer_h_manual_mst", "t_nala_cstmr_pnl_kpi_mapping") }}
),
joined as (
  -- Add mapping logic here
  select
    FARM_FINGERPRINT(CONCAT(farm_fingerprint(concat(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.kpi_name;amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.cluster_code_nk; amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account;'SAPS4_AM_NA'))) as pnl_kpi_sk,
    cast(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L1_Global as string) as kpi_level_1,
    cast(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L2_Global as string) as kpi_level_2,
    cast(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L3_Global as string) as kpi_level_3,
    cast(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L4_NA as string) as kpi_level_4,
    cast(Placeholder as string) as kpi_level_5,
    cast(Placeholder as string) as kpi_level_6,
    cast(Placeholder as string) as kpi_level_7,
    cast(Placeholder as string) as kpi_level_8,
    cast(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L4_NA as string) as kpi_name,
    cast(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_accountjoin amer_h_saps4_am.t_acdocaon amer_h_saps4_am.t_acdoca.racct = amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account as string) as gl_account_nb_nk,
    cast(NA as string) as cluster_code_nk,
    cast(placeholder as string) as sign_multiplier,
    cast(placeholder as string) as additive_flg,
    cast(placeholder as string) as kpi_formula,
    cast(SAPS4_AM_NA as string) as source_system
  from kpi
  -- Add joins as per mapping logic
)
select
  pnl_kpi_sk,
  kpi_level_1,
  kpi_level_2,
  kpi_level_3,
  kpi_level_4,
  kpi_level_5,
  kpi_level_6,
  kpi_level_7,
  kpi_level_8,
  kpi_name,
  gl_account_nb_nk,
  cluster_code_nk,
  sign_multiplier,
  additive_flg,
  kpi_formula,
  source_system
from joined