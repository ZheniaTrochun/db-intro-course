-- the database should have 8 application tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- all tables must contain sample data
SELECT 'customer' AS table_name, COUNT(*) AS rows_count FROM customer
UNION ALL SELECT 'category', COUNT(*) FROM category
UNION ALL SELECT 'product', COUNT(*) FROM product
UNION ALL SELECT 'customer_order', COUNT(*) FROM customer_order
UNION ALL SELECT 'order_item', COUNT(*) FROM order_item
UNION ALL SELECT 'product_category', COUNT(*) FROM product_category
UNION ALL SELECT 'payment', COUNT(*) FROM payment
UNION ALL SELECT 'shipment', COUNT(*) FROM shipment
ORDER BY table_name;

-- the customer, order, and order items are linked by foreign keys
SELECT o.order_id, c.full_name, p.name AS product_name,
       oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM customer_order AS o
JOIN customer AS c ON c.customer_id = o.customer_id
JOIN order_item AS oi ON oi.order_id = o.order_id
JOIN product AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_id;

-- each order's total from the stored historical prices
SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_total
FROM customer_order AS o
JOIN order_item AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY o.order_id;

-- see how a product belongs to multiple categories
SELECT p.name AS product_name, c.name AS category_name
FROM product_category AS pc
JOIN product AS p ON p.product_id = pc.product_id
JOIN category AS c ON c.category_id = pc.category_id
ORDER BY p.product_id, c.category_id;

-- 6. Inspect PK, FK, UNIQUE, and CHECK definitions
SELECT t.relname AS table_name, c.conname AS constraint_name,
       CASE c.contype
           WHEN 'p' THEN 'PRIMARY KEY'
           WHEN 'f' THEN 'FOREIGN KEY'
           WHEN 'u' THEN 'UNIQUE'
           WHEN 'c' THEN 'CHECK'
       END AS constraint_type
FROM pg_constraint AS c
JOIN pg_class AS t ON t.oid = c.conrelid
JOIN pg_namespace AS n ON n.oid = t.relnamespace
WHERE n.nspname = 'public'
  AND c.contype IN ('p', 'f', 'u', 'c')
ORDER BY t.relname, constraint_type, c.conname;
