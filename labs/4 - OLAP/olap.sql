-- Лабораторна робота №4. Аналітичні запити для інтернет-магазину.

-- 1. Кількість товарів, середня, мінімальна та максимальна ціна.
SELECT
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM product;


-- 2. Загальна сума успішних платежів.
-- Очікувані та невдалі платежі до підсумку не входять.
SELECT SUM(amount) AS successful_payment_total
FROM payment
WHERE status = 'successful';


-- 3. Кількість замовлень за кожним статусом.
SELECT
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY status;


-- 4. Нескасовані замовлення вартістю понад 2000 грн.
-- Вартість визначається за кількістю і ціною позицій замовлення.
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.unit_price) AS total_amount
FROM orders AS o
INNER JOIN customer AS c
    ON c.customer_id = o.customer_id
INNER JOIN order_item AS oi
    ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY o.order_id, c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.unit_price) > 2000
ORDER BY o.order_id;