-- Скільки всього товарів у каталозі
SELECT COUNT(*) AS total_products
FROM product;
-- Середня, мінімальна та максимальна ціна товару
SELECT 
    AVG(product_price) AS avg_price,
    MIN(product_price) AS min_price,
    MAX(product_price) AS max_price
FROM product;
-- Скільки всього одиниць товару на складі
SELECT SUM(product_item_stock_quantity) AS total_stock
FROM product_item;
-- Кількість замовлень за кожним статусом
SELECT order_status, COUNT(*) AS orders_count
FROM "order"
GROUP BY order_status;
-- Залишок на складі за кольором
SELECT product_item_color, SUM(product_item_stock_quantity) AS stock_sum
FROM product_item
GROUP BY product_item_color;
-- Кольори, де залишок на складі більший за 20
SELECT product_item_color, SUM(product_item_stock_quantity) AS stock_sum
FROM product_item
GROUP BY product_item_color
HAVING SUM(product_item_stock_quantity) > 20;
-- INNER JOIN: замовлення та імена клієнтів
SELECT o.order_id, c.first_name, c.last_name, o.order_price
FROM "order" o
INNER JOIN customer c ON o.customer_id = c.customer_id;
-- LEFT JOIN: усі категорії та їхні товари (навіть якщо товарів немає)
SELECT cat.category_name, p.product_name
FROM category cat
LEFT JOIN product p ON cat.category_id = p.category_id;
-- FULL OUTER JOIN: усі замовлення та усі оплати
SELECT o.order_id, o.order_price, pay.payment_amount, pay.payment_method
FROM "order" o
FULL OUTER JOIN payment pay ON o.order_id = pay.order_id;
-- CROSS JOIN: усі комбінації категорій та розмірів
SELECT cat.category_name, pi.product_item_size
FROM category cat
CROSS JOIN product_item pi;
-- Сума замовлень кожного клієнта
SELECT c.first_name, c.last_name, SUM(o.order_price) AS total_orders_sum
FROM customer c
LEFT JOIN "order" o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
-- Кількість проданих одиниць по кожному товару
SELECT p.product_name, SUM(oi.order_item_quantity) AS sold_qty
FROM product p
LEFT JOIN product_item pi ON p.product_id = pi.product_id
LEFT JOIN order_item oi ON pi.product_item_id = oi.product_item_id
GROUP BY p.product_id, p.product_name;
-- Підзапит у WHERE: товари дорожчі за середню ціну
SELECT product_name, product_price
FROM product
WHERE product_price > (SELECT AVG(product_price) FROM product);
-- Підзапит у SELECT: ціна товару і середня ціна по каталогу
SELECT 
    product_name,
    product_price,
    (SELECT AVG(product_price) FROM product) AS avg_price
FROM product;
-- Підзапит у HAVING: клієнти, чий середній чек вищий за загальний середній чек
SELECT c.first_name, c.last_name, AVG(o.order_price) AS avg_customer_order
FROM customer c
JOIN "order" o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING AVG(o.order_price) > (SELECT AVG(order_price) FROM "order");