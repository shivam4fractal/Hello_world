with account as (
  select * from {{ source('amer_h_saps4_am', 't_ska1') }}
)
select
  FARM_FINGERPRINT(CONCAT(FARM_FINGERPRINT( CONCAT( amer_h_saps4_am.t_acdoca.ktopl; '|'; amer_h_saps4_am.t_acdoca.rbukrs; '|'; amer_h_saps4_am.t_acdoca.racct;  '|'; amer_h_saps4_am.t_ska1.bilkt;    '|'; amer_h_saps4_am.t_ska1.ktoks;    '|'; amer_h_saps4_am.t_ska1.gvtyp;    '|'; 'SAPS4_AM_NA')) as account_cust_pnl_sk,
  trim(amer_h_saps4_am.t_acdoca.racct;'0') as gl_account_nb_nk,
  amer_h_saps4_am.t_acdoca.rbukrs as company_code_nk,
  amer_h_saps4_am.t_acdoca.ktopl as chart_of_accounts_directory_nk,
  amer_h_saps4_am.t_acdoca.gvtyp

join amer_h_saps4_am.t_acdoca
on amer_h_saps4_am.t_acdoca.racct = amer_h_saps4_am.t_ska1.saknr as pnl_statement_account_type,
  amer_h_saps4_am.t_acdoca.ktoks

join amer_h_saps4_am.t_acdoca
on amer_h_saps4_am.t_acdoca.racct = amer_h_saps4_am.t_ska1.saknr as gl_account_type,
  amer_h_saps4_am.t_acdoca.bilkt

join amer_h_saps4_am.t_acdoca
on amer_h_saps4_am.t_acdoca.racct = amer_h_saps4_am.t_ska1.saknr as group_account_number,
  SAPS4_AM_NA'  as source_system
from account