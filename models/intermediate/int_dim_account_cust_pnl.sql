with ska1 as (
  select * from {{ source('amer_h_saps4_am', 't_ska1') }}
)
select
  cast(account_cust_pnl_sk as string) as account_cust_pnl_sk,
  cast(gl_account_nb_nk as string) as gl_account_nb_nk,
  cast(company_code_nk as string) as company_code_nk,
  cast(chart_of_accounts_directory_nk as string) as chart_of_accounts_directory_nk,
  cast(pnl_statement_account_type as string) as pnl_statement_account_type,
  cast(gl_account_type as string) as gl_account_type,
  cast(group_account_number as string) as group_account_number,
  cast(source_system as string) as source_system
from ska1