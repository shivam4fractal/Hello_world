with fact as (
  select * from {{ ref('int_fct_customer_pnl') }}
),
     prod as (
  select * from {{ ref('int_dim_product_cust_pnl') }}
),
     kpi as (
  select * from {{ ref('int_dim_pnl_kpi') }}
),
     org as (
  select * from {{ ref('int_dim_fi_org') }}
),
     acct as (
  select * from {{ ref('int_dim_account_cust_pnl') }}
)
select
  fact.*,
  prod.*,
  kpi.*,
  org.*,
  acct.*
from fact
  left join prod on ...
  left join kpi on ...
  left join org on ...
  left join acct on ...