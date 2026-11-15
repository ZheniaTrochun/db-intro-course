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

-- 5. INNER JOIN: замовлення з даними їхніх покупців.
SELECT
    o.order_id,
    o.order_date,
    o.status,
    c.first_name,
    c.last_name
FROM orders AS o
INNER JOIN customer AS c
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;


-- 6. LEFT JOIN: усі товари та їхні відгуки.
-- Товари без відгуків також залишаються в результаті.
SELECT
    p.product_id,
    p.name,
    r.review_id,
    r.rating,
    r.comment
FROM product AS p
LEFT JOIN review AS r
    ON r.product_id = p.product_id
ORDER BY p.product_id, r.review_id;


-- 7. RIGHT JOIN: товари, на які ще немає відгуків.
-- Зберігаємо всі товари з правої таблиці,
-- а потім залишаємо лише ті, для яких відгук не знайдено.
SELECT
    p.product_id,
    p.name
FROM review AS r
RIGHT JOIN product AS p
    ON p.product_id = r.product_id
WHERE r.review_id IS NULL
ORDER BY p.product_id;