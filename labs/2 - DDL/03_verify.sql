-- в усіх таблицях є умовні дані
SELECT *
FROM (VALUES
    ('customer', (SELECT COUNT(*) FROM customer)),
    ('category', (SELECT COUNT(*) FROM category)),
    ('product', (SELECT COUNT(*) FROM product)),
    ('customer_order', (SELECT COUNT(*) FROM customer_order)),
    ('order_item', (SELECT COUNT(*) FROM order_item)),
    ('product_category', (SELECT COUNT(*) FROM product_category)),
    ('payment', (SELECT COUNT(*) FROM payment)),
    ('shipment', (SELECT COUNT(*) FROM shipment))
) AS t(table_name, rows_count)
ORDER BY table_name;

-- покупець, замовлення і товари в замовленні обєднані первинними ключами
SELECT o.order_id, c.full_name, p.name AS product_name,
       oi.quantity, oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM customer_order AS o
JOIN customer AS c ON c.customer_id = o.customer_id
JOIN order_item AS oi ON oi.order_id = o.order_id
JOIN product AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_id;

-- загальна вартість кожного замовлення
SELECT order_id,
       SUM(quantity * unit_price) AS order_total
FROM order_item
GROUP BY order_id
ORDER BY order_id;

-- назви товарів та категорій, до яких вони належать
SELECT p.name AS product_name, c.name AS category_name
FROM product_category AS pc
JOIN product AS p ON p.product_id = pc.product_id
JOIN category AS c ON c.category_id = pc.category_id
ORDER BY p.product_id, c.category_id;

-- перевірка обмежень в базі даних
SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public'
  AND constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE', 'CHECK')
ORDER BY table_name, constraint_type, constraint_name;