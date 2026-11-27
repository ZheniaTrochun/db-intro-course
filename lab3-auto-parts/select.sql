-- Lab 3: SELECT. Run on the initial Lab 2 data before other scripts.
-- S1. Product catalogue (10 rows).
SELECT product_id, name, sku, price, stock_quantity
FROM products
ORDER BY product_id;

-- S2. Available filters costing at most 600 (2 rows).
SELECT p.name, p.price, p.stock_quantity
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE c.name = 'Filters' AND p.price <= 600 AND p.stock_quantity > 0
ORDER BY p.price;

-- S3. Low stock (3 rows).
SELECT sku, name, stock_quantity
FROM products
WHERE stock_quantity < 5
ORDER BY stock_quantity, sku;

-- S4. Order history of customer 1 (2 rows initially).
SELECT o.order_id, c.first_name, c.last_name, o.order_date, o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id = 1
ORDER BY o.order_id;

-- S5. Products with their categories and suppliers (10 rows).
SELECT p.name AS product, c.name AS category, s.name AS supplier
FROM products p
JOIN categories c ON c.category_id = p.category_id
JOIN suppliers s ON s.supplier_id = p.supplier_id
ORDER BY p.product_id;

-- S6. Order 1 details (2 rows). Use historical prices, not products.price.
SELECT p.name, oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.order_id = 1
ORDER BY oi.order_item_id;

-- S7. Orders with a total above 2500 (3 rows).
SELECT o.order_id, o.status, SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status
HAVING SUM(oi.quantity * oi.unit_price) > 2500
ORDER BY o.order_id;
