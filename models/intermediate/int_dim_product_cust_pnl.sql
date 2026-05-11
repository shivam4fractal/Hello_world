with material as (
  select * from {{ source("amer_dc_md", "t_dim_material") }}
)
select
  {{ farm_fingerprint(["product_sk"]) }} as product_sk,
  select material_cd where acdoca.matnr = material.material_cd
union
select subbrand_nm where acdoca.ZZ1_GPHLVL5_MSE= material.prod_hier_l9_cd as product_cd_nk,
  "select  ""SKU"" where acdoca.matnr = material.material_cd as product_type,
  amer_dc_md.t_dim_material.is_current as is_current,
  amer_dc_md.t_dim_material.validity_start_dt as validity_start_dt,
  amer_dc_md.t_dim_material.validity_end_dt as validity_end_dt,
  amer_dc_md.t_dim_material.product_type_cd as product_type_cd,
  amer_dc_md.t_dim_material.product_hierarchy_cd as product_hierarchy_cd,
  amer_dc_md.t_dim_material.product_group_cd as product_group_cd,
  amer_dc_md.t_dim_material.glbl_brand_cd as glbl_brand_cd,
  amer_dc_md.t_dim_material.glbl_brand_nm as glbl_brand_nm,
  amer_dc_md.t_dim_material.glbl_subbrand_nm as glbl_subbrand_nm,
  amer_dc_md.t_dim_material.glbl_variant_nm as glbl_variant_nm,
  amer_dc_md.t_dim_material.na_brand_cd as local_brand_cd,
  amer_dc_md.t_dim_material.na_brand_ds as local_brand_ds,
  amer_dc_md.t_dim_material.na_subbrand_cd as local_subbrand_cd,
  amer_dc_md.t_dim_material.na_subbrand_ds as local_subbrand_ds,
  amer_dc_md.t_dim_material.base_unit_of_measure_cd as base_unit_of_measure_cd,
  amer_dc_md.t_dim_material.net_contents_qt as net_contents_qt,
  amer_dc_md.t_dim_material.content_unit_cd as content_unit_cd,
  amer_dc_md.t_dim_material.net_weight_vl as net_weight_vl,
  amer_dc_md.t_dim_material.weight_unit_cd as weight_unit_cd,
  amer_dc_md.t_dim_material.volume_vl as volume_vl,
  amer_dc_md.t_dim_material.volume_unit_cd as volume_unit_cd,
  amer_dc_md.t_dim_material.glbl_gtin_nb as glbl_gtin_nb,
  amer_dc_md.t_dim_material.country_origin_cd as country_origin_cd,
  amer_dc_md.t_dim_material.cross_plant_material_status_cd as cross_plant_material_status_cd,
  amer_dc_md.t_dim_material.deletion_client_level_fl as deletion_client_level_fl,
  amer_dc_md.t_dim_material.pricing_ref_material_cd as pricing_ref_material_cd,
  amer_dc_md.t_dim_material.general_item_category_group_cd as general_item_category_group_cd,
  "select characteristic_value_vl from amer_dc_md.t_dim_material_classification
where class_name_nm = """"Z_MATERIAL_GENERAL"""" and characteristic_name_nm = 'Snack Type'" as snack_type,
  SAPS4_AM_NA as source_system
from material