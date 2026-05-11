with fct as (
  select * from {{ ref("int_fct_customer_pnl") }}
),
product as (
  select * from {{ ref("int_dim_product_cust_pnl") }}
),
kpi as (
  select * from {{ ref("int_dim_pnl_kpi") }}
),
fi_org as (
  select * from {{ ref("int_dim_fi_org") }}
),
account as (
  select * from {{ ref("int_dim_account_cust_pnl") }}
)
select fct.*, product.*, kpi.*, fi_org.*, account.*
from fct
left join product on fct.product_id = product.product_id
left join kpi on fct.kpi_id = kpi.kpi_id
left join fi_org on fct.fi_org_id = fi_org.fi_org_id
left join account on fct.account_id = account.account_id