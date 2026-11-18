-- ============================================================================
-- Лабораторна робота №4: Аналітичні SQL-запити (OLAP)
-- Предметна область: Інтернет-магазин електроніки «TechStore»
-- Виконала: Лінчевська Анастасія, група ІМ-о51
-- ============================================================================

-- ============================================================================
-- БЛОК 1: АГРЕГАЦІЙНІ ФУНКЦІЇ
-- ============================================================================

-- Запит 1.1: Базова агрегація по каталогу товарів
-- (загальна кількість моделей, сумарний залишок на складі, середня, мінімальна та максимальна ціна)
SELECT
    COUNT(*)                     AS total_products,
    SUM(stock_quantity)          AS total_units_in_stock,
    ROUND(AVG(price), 2)         AS avg_product_price,
    MIN(price)                   AS min_product_price,
    MAX(price)                   AS max_product_price
FROM products;

-- Запит 1.2: Групування замовлень за містом доставки (GROUP BY)
-- (кількість замовлень, загальна сума виручки та середній чек по кожному місту)
SELECT
    shipping_city,
    COUNT(*)                     AS orders_count,
    SUM(total_amount)            AS city_total_revenue,
    ROUND(AVG(total_amount), 2)  AS avg_order_amount
FROM orders
WHERE status <> 'cancelled'
GROUP BY shipping_city
ORDER BY city_total_revenue DESC;

-- Запит 1.3: Статистика за способами оплати (GROUP BY)
-- (кількість платежів, мінімальний, максимальний та сумарний обсяг транзакцій)
SELECT
    payment_method,
    COUNT(*)                     AS payments_count,
    MIN(amount)                  AS min_payment,
    MAX(amount)                  AS max_payment,
    SUM(amount)                  AS total_paid_amount
FROM payments
WHERE payment_status = 'completed'
GROUP BY payment_method
ORDER BY total_paid_amount DESC;

-- Запит 1.4: Фільтрація згрупованих даних за допомогою HAVING
-- (пошук категорій, у яких середня вартість товару перевищує 15 000 грн)
SELECT
    category_id,
    COUNT(*)                     AS products_in_category,
    ROUND(AVG(price), 2)         AS avg_category_price,
    SUM(stock_quantity)          AS total_category_stock
FROM products
GROUP BY category_id
HAVING AVG(price) > 15000.00
ORDER BY avg_category_price DESC;

-- ============================================================================
-- БЛОК 2: ОПЕРАЦІЇ ОБ'ЄДНАННЯ ТАБЛИЦЬ — JOIN (мінімум 3 запити різних типів)
-- ============================================================================

-- Запит 2.1: INNER JOIN (багатотабличне об'єднання 4 таблиць + агрегація)
-- (загальна сума витрат та кількість куплених одиниць товару для кожного клієнта)
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(DISTINCT o.order_id)           AS total_orders,
    SUM(oi.quantity)                     AS total_items_bought,
    SUM(oi.quantity * oi.unit_price)     AS total_spent_on_items
FROM customers c
INNER JOIN orders o       ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY total_spent_on_items DESC;

-- Запит 2.2: LEFT JOIN
-- (отримання повного списку клієнтів, включаючи тих, які ще не оформили жодного замовлення)
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(o.order_id)                    AS orders_count,
    COALESCE(SUM(o.total_amount), 0.00)  AS total_orders_sum
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY orders_count DESC, c.customer_id ASC;

-- Запит 2.3: RIGHT JOIN та FULL OUTER JOIN
-- (аналіз замовлень у розрізі всіх товарів та категорій, включаючи товари без продажів)
SELECT
    cat.name                             AS category_name,
    p.product_id,
    p.name                               AS product_name,
    p.price                              AS catalog_price,
    COALESCE(SUM(oi.quantity), 0)        AS units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS product_revenue
FROM order_items oi
RIGHT JOIN products p    ON oi.product_id = p.product_id
FULL OUTER JOIN categories cat ON p.category_id = cat.category_id
GROUP BY cat.name, p.product_id, p.name, p.price
ORDER BY product_revenue DESC, p.price DESC;

-- ============================================================================
-- БЛОК 3: ПІДЗАПИТИ У WHERE, SELECT ТА HAVING (мінімум 3 запити)
-- ============================================================================

-- Запит 3.1: Підзапит у WHERE
-- (знайти всі товари, ціна яких вища за середню ціну по всьому каталогу магазину)
SELECT
    product_id,
    name,
    legacy_sku,
    price,
    stock_quantity
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
)
ORDER BY price DESC;

-- Запит 3.2: Скалярні підзапити у SELECT
-- (виведення кожної категорії разом із кількістю товарів у ній та назвою найдорожчого товару)
SELECT
    c.category_id,
    c.name AS category_name,
    (
        SELECT COUNT(*)
        FROM products p
        WHERE p.category_id = c.category_id
    ) AS product_count,
    (
        SELECT MAX(p.price)
        FROM products p
        WHERE p.category_id = c.category_id
    ) AS max_price_in_category
FROM categories c
ORDER BY max_price_in_category DESC;

-- Запит 3.3: Підзапит у HAVING
-- (знайти клієнтів, загальна сума замовлень яких перевищує середній чек замовлення по магазину)
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS orders_count,
    SUM(o.total_amount) AS customer_total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id, c.full_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(total_amount)
    FROM orders
    WHERE status <> 'cancelled'
)
ORDER BY customer_total_spent DESC;

