with fact as (
  select * from {{ ref('int_fct_customer_pnl') }}
),
product as (
  select * from {{ ref('int_dim_product_cust_pnl') }}
),
kpi as (
  select * from {{ ref('int_dim_pnl_kpi') }}
),
fi_org as (
  select * from {{ ref('int_dim_fi_org') }}
),
account as (
  select * from {{ ref('int_dim_account_cust_pnl') }}
)
select
  fact.*,
  product.*,
  kpi.*,
  fi_org.*,
  account.*
from fact
left join product on fact.product_id = product.product_id
left join kpi on fact.kpi_id = kpi.kpi_id
left join fi_org on fact.org_id = fi_org.org_id
left join account on fact.account_id = account.account_id