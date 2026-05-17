with fact as (
  select * from {{ ref('int_fct_customer_pnl') }}
),
product as (
  select * from {{ ref('int_dim_product_cust_pnl') }}
)
select
  fact.*,
  product.*
from fact
left join product on fact.product_id = product.product_id