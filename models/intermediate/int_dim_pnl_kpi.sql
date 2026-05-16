with kpi as (
  select
    FARM_FINGERPRINT(CONCAT(farm_fingerprint(concat(amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.kpi_name;amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.cluster_code_nk; amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account;'SAPS4_AM_NA')
)) as pnl_kpi_sk,
    amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L1_Global as kpi_level_1,
    amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L2_Global as kpi_level_2,
    amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L3_Global as kpi_level_3,
    amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L4_NA as kpi_level_4,
    Placeholder as kpi_level_5,
    Placeholder as kpi_level_6,
    Placeholder as kpi_level_7,
    Placeholder as kpi_level_8,
    amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.L4_NA as kpi_name,
    amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account

join amer_h_saps4_am.t_acdoca
on amer_h_saps4_am.t_acdoca.racct = amer_h_manual_mst.t_nala_cstmr_pnl_kpi_mapping.gl_account as gl_account_nb_nk,
    cluster_code_nk,
    placeholder as sign_multiplier,
    placeholder as additive_flg,
    placeholder as kpi_formula,
    SAPS4_AM_NA as source_system
  from {{ source('amer_h_manual_mst', 't_nala_cstmr_pnl_kpi_mapping') }}
)
select * from kpi