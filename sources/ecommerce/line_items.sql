SELECT 
  ORDER_ID as order_id,
  PRINT_PROVIDER_ID as print_provider_id,
  PRODUCT_BRAND as product_brand,
  PRODUCT_TYPE as product_type,
  QUANTITY as quantity,
  REPRINT_FLAG as reprint_flag
FROM ecommerce.line_items