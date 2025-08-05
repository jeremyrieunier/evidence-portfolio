SELECT 
  MERCHANT_ID as merchant_id,
  ORDER_ID as order_id,
  SHOP_ID as shop_id,
  ADDRESS_TO_COUNTRY as address_to_country,
  ADDRESS_TO_REGION as address_to_region,
  ORDER_DT as order_dt,
  FULFILLED_DT as fulfilled_dt,
  SALES_CHANNEL_TYPE_ID as sales_channel_type_id,
  TOTAL_COST as total_cost,
  TOTAL_SHIPPING as total_shipping,
  MERCHANT_REGISTERED_DT as merchant_registered_dt,
  SUB_IS_ACTIVE_FLAG as sub_is_active_flag,
  SUB_PLAN as sub_plan,
  SHIPMENT_CARRIER as shipment_carrier,
  SHIPMENT_DELIVERED_AT as shipment_delivered_at
FROM ecommerce.orders