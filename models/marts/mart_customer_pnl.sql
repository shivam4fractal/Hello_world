with fct as (
  select * from {{ ref('int_fct_customer_pnl') }}
),
product as (
  select * from {{ ref('int_dim_product_cust_pnl') }}
),
kpi as (
  select * from {{ ref('int_dim_pnl_kpi') }}
),
org as (
  select * from {{ ref('int_dim_fi_org') }}
),
acc as (
  select * from {{ ref('int_dim_account_cust_pnl') }}
)
select
  fct.*,
  product.*,
  kpi.*,
  org.*,
  acc.*
from fct
left join product on fct.product_id = product.product_id
left join kpi on fct.kpi_id = kpi.kpi_id
left join org on fct.org_id = org.org_id
left join acc on fct.account_id = acc.account_id