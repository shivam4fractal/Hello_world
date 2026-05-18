with account as (
  select * from {{ source("amer_h_saps4_am", "t_ska1") }}
),
joined as (
  -- Add mapping logic here
  select
    FARM_FINGERPRINT(CONCAT(FARM_FINGERPRINT( CONCAT( amer_h_saps4_am.t_acdoca.ktopl; '|'; amer_h_saps4_am.t_acdoca.rbukrs; '|'; amer_h_saps4_am.t_acdoca.racct;  '|'; amer_h_saps4_am.t_ska1.bilkt;    '|'; amer_h_saps4_am.t_ska1.ktoks;    '|'; amer_h_saps4_am.t_ska1.gvtyp;    '|'; 'SAPS4_AM_NA')) as account_cust_pnl_sk,
    cast(trim(amer_h_saps4_am.t_acdoca.racct;'0') as string) as gl_account_nb_nk,
    cast(amer_h_saps4_am.t_acdoca.rbukrs as string) as company_code_nk,
    cast(amer_h_saps4_am.t_acdoca.ktopl as string) as chart_of_accounts_directory_nk,
    cast(amer_h_saps4_am.t_acdoca.gvtypjoin amer_h_saps4_am.t_acdocaon amer_h_saps4_am.t_acdoca.racct = amer_h_saps4_am.t_ska1.saknr as string) as pnl_statement_account_type,
    cast(amer_h_saps4_am.t_acdoca.ktoksjoin amer_h_saps4_am.t_acdocaon amer_h_saps4_am.t_acdoca.racct = amer_h_saps4_am.t_ska1.saknr as string) as gl_account_type,
    cast(amer_h_saps4_am.t_acdoca.bilktjoin amer_h_saps4_am.t_acdocaon amer_h_saps4_am.t_acdoca.racct = amer_h_saps4_am.t_ska1.saknr as string) as group_account_number,
    cast(SAPS4_AM_NA'  as string) as source_system
  from account
  -- Add joins as per mapping logic
)
select
  account_cust_pnl_sk,
  gl_account_nb_nk,
  company_code_nk,
  chart_of_accounts_directory_nk,
  pnl_statement_account_type,
  gl_account_type,
  group_account_number,
  source_system
from joined