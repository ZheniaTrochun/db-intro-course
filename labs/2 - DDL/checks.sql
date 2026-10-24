-- 1. Кількість записів у кожній таблиці.
SELECT 'customer' AS table_name, COUNT(*) AS row_count FROM customer
UNION ALL
SELECT 'address', COUNT(*) FROM address
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'product', COUNT(*) FROM product
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_item', COUNT(*) FROM order_item
UNION ALL
SELECT 'payment', COUNT(*) FROM payment
UNION ALL
SELECT 'review', COUNT(*) FROM review
ORDER BY table_name;


-- 2. Замовлення, клієнти та адреси доставки.
SELECT
    o.order_id,
    c.first_name,
    c.last_name,
    a.city,
    a.street,
    a.building,
    o.status
FROM orders AS o
JOIN customer AS c
    ON c.customer_id = o.customer_id
JOIN address AS a
    ON a.address_id = o.address_id
    AND a.customer_id = o.customer_id
ORDER BY o.order_id;


-- 3. Вартість замовлень та сума успішних оплат.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS total_amount
    FROM order_item
    GROUP BY order_id
),
payment_totals AS (
    SELECT
        order_id,
        SUM(amount) AS paid_amount
    FROM payment
    WHERE status = 'successful'
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.status,
    t.total_amount,
    COALESCE(p.paid_amount, 0) AS paid_amount,
    t.total_amount - COALESCE(p.paid_amount, 0) AS unpaid_amount
FROM orders AS o
JOIN order_totals AS t
    ON t.order_id = o.order_id
LEFT JOIN payment_totals AS p
    ON p.order_id = o.order_id
ORDER BY o.order_id;


-- 4. Пошук замовлень без позицій.
SELECT o.order_id
FROM orders AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM order_item AS oi
    WHERE oi.order_id = o.order_id
);


-- 5. Пошук невідповідності статусу та суми оплати.
WITH amounts AS (
    SELECT
        o.order_id,
        o.status,
        COALESCE((
            SELECT SUM(oi.quantity * oi.unit_price)
            FROM order_item AS oi
            WHERE oi.order_id = o.order_id
        ), 0) AS total_amount,
        COALESCE((
            SELECT SUM(p.amount)
            FROM payment AS p
            WHERE p.order_id = o.order_id
              AND p.status = 'successful'
        ), 0) AS paid_amount
    FROM orders AS o
)
SELECT *
FROM amounts
WHERE (
    status IN ('paid', 'shipped', 'delivered')
    AND paid_amount <> total_amount
)
OR (
    status = 'new'
    AND total_amount > 0
    AND paid_amount = total_amount
);


-- 6. Перевірка обмежень на некоректних даних.

BEGIN;

DO $$
BEGIN
    -- Повторний email.
    BEGIN
        UPDATE customer
        SET email = 'anna@example.com'
        WHERE customer_id = 2;

        RAISE EXCEPTION 'FAIL: база дозволила повторний email';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'OK: повторний email заборонено';
    END;

    -- Від’ємна ціна товару.
    BEGIN
        UPDATE product
        SET price = -100
        WHERE product_id = 1;

        RAISE EXCEPTION 'FAIL: база дозволила від’ємну ціну';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: від’ємну ціну заборонено';
    END;

    -- Нульова кількість товару в замовленні.
    BEGIN
        UPDATE order_item
        SET quantity = 0
        WHERE order_id = 1 AND product_id = 1;

        RAISE EXCEPTION 'FAIL: база дозволила нульову кількість';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: нульову кількість заборонено';
    END;

    -- Чужа адреса: адреса №3 належить клієнту №2,
    -- а замовлення №1 належить клієнту №1.
    BEGIN
        UPDATE orders
        SET address_id = 3
        WHERE order_id = 1;

        RAISE EXCEPTION 'FAIL: база дозволила чужу адресу';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'OK: чужу адресу доставки заборонено';
    END;

    -- Повторний товар у тому самому замовленні.
    BEGIN
        INSERT INTO order_item
            (order_id, product_id, quantity, unit_price)
        VALUES
            (1, 1, 1, 1200.00);
        RAISE EXCEPTION 'FAIL: база дозволила повторну позицію';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'OK: повторну позицію заборонено';
    END;

    -- Оцінка за межами 1–5.
    BEGIN
        UPDATE review
        SET rating = 6
        WHERE review_id = 1;

        RAISE EXCEPTION 'FAIL: база дозволила оцінку 6';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: оцінку поза діапазоном заборонено';
    END;

    -- Повторний відгук клієнта №1 про товар №1.
    BEGIN
        UPDATE review
        SET customer_id = 1, product_id = 1
        WHERE review_id = 2;

        RAISE EXCEPTION 'FAIL: база дозволила повторний відгук';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'OK: повторний відгук заборонено';
    END;

    -- Успішний платіж без часу оплати.
    BEGIN
        UPDATE payment
        SET paid_at = NULL
        WHERE payment_id = 1;

        RAISE EXCEPTION 'FAIL: успішний платіж прийнято без дати';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'OK: успішний платіж вимагає дати';
    END;
END;
$$;

ROLLBACK;
