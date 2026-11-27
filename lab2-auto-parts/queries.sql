-- 1. Row counts for all seven tables. Expected total: 46.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments;

-- 2. Product catalog with category and supplier.
SELECT p.product_id, p.name AS product, p.sku, c.name AS category,
       s.name AS supplier, p.price, p.stock_quantity
FROM products p
JOIN categories c ON c.category_id = p.category_id
JOIN suppliers s ON s.supplier_id = p.supplier_id
ORDER BY p.product_id;

-- 3. Order totals. Use historical prices, not current product prices.
SELECT o.order_id, c.first_name, c.last_name, o.status,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, c.first_name, c.last_name, o.status
ORDER BY o.order_id;

-- 4. Successful payments only. Expected: 8350.00.
SELECT COALESCE(SUM(amount), 0) AS successful_payment_total
FROM payments
WHERE status = 'successful';

-- 5. Low stock, including out-of-stock products.
SELECT sku, name, stock_quantity FROM products
WHERE stock_quantity < 5 ORDER BY stock_quantity, product_id;

-- 6. Check the historical price of the oil filter in order 1.
SELECT oi.order_id, p.name, oi.unit_price AS historical_price,
       p.price AS current_price
FROM order_items oi JOIN products p ON p.product_id = oi.product_id
WHERE oi.order_id = 1 AND p.sku = 'FL-001';

-- 7. Check that no existing order is empty. Expected: 0 rows.
SELECT o.order_id FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_item_id IS NULL;
