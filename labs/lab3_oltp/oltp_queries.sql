-- ============================================================================
-- Лабораторна робота №3: Маніпулювання даними SQL (OLTP)
-- Предметна область: Інтернет-магазин електроніки «TechStore»
-- Виконала: Лінчевська Анастасія, група ІМ-о51
-- ============================================================================

-- ============================================================================
-- ЧАСТИНА 1: ОТРИМАННЯ ДАНИХ (SELECT із фільтрацією WHERE)
-- ============================================================================

-- Запит 1.1: Отримання списку клієнтів із міста Київ 
SELECT customer_id, full_name, email, phone
FROM customers
WHERE city = 'Київ'
ORDER BY full_name;

-- Запит 1.2: Пошук товарів у категорії «Ноутбуки» або «Смартфони» дорожчих за 48 000 грн
SELECT product_id, name, legacy_sku, price, stock_quantity
FROM products
WHERE category_id IN (1, 2)
  AND price > 48000.00
ORDER BY price DESC;

-- Запит 1.3: Перегляд активних замовлень (оплачених, відправлених або завершених) на суму понад 30 000 грн
SELECT order_id, customer_id, order_date, status, shipping_city, total_amount
FROM orders
WHERE status IN ('paid', 'shipped', 'completed')
  AND total_amount > 30000.00
ORDER BY order_date DESC;

-- ============================================================================
-- ЧАСТИНА 2: ДОДАВАННЯ НОВИХ ДАНИХ (INSERT INTO) ТА ПЕРЕВІРКА
-- ============================================================================

-- Запит 2.1: Реєстрація нового клієнта в магазині
INSERT INTO customers (full_name, email, phone, city)
VALUES ('Вікторія Лисенко', 'v.lysenko@gmail.com', '+380679998877', 'Харків');

-- Перевірка доданого клієнта
SELECT customer_id, full_name, email, phone, city, created_at
FROM customers
WHERE email = 'v.lysenko@gmail.com';

-- Запит 2.2: Додавання нового товару в категорію «Аксесуари та периферія» (category_id = 5)
INSERT INTO products (
    category_id, name, legacy_sku, price, stock_quantity,
    tags, supplier_name, supplier_phone, supplier_email
)
VALUES (
    5, 'Бездротова миша Logitech MX Master 3S', 'SKU-ACC-002', 4599.00, 20,
    'mouse, wireless, ergonomic, logitech', 'ТОВ СаундПро', '+380445004040', 'sales@soundpro.ua'
);

-- Перевірка доданого товару
SELECT product_id, category_id, name, legacy_sku, price, stock_quantity
FROM products
WHERE legacy_sku = 'SKU-ACC-002';

-- Запит 2.3: Оформлення нового замовлення для нового клієнта (customer_id = 7) та додавання позиції
INSERT INTO orders (
    order_id, customer_id, order_date, status,
    shipping_address, shipping_city, city_delivery_tariff, total_amount
)
VALUES (
    7, 7, '2026-10-05 14:15:00', 'pending',
    'вул. Сумська, 77, кв. 12', 'Харків', 150.00, 4749.00
);

INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price)
VALUES (7, 9, 'Бездротова миша Logitech MX Master 3S', 1, 4599.00);

-- Перевірка створеного замовлення та його позиції
SELECT o.order_id, o.customer_id, o.status, o.total_amount, oi.product_name, oi.quantity, oi.unit_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_id = 7;

-- ============================================================================
-- ЧАСТИНА 3: ОНОВЛЕННЯ ІСНУЮЧИХ ДАНИХ (UPDATE ... SET ... WHERE) ТА ПЕРЕВІРКА
-- ============================================================================

-- Запит 3.1: Зменшення залишку товару на складі та акційне зниження ціни для миші Logitech (product_id = 9)
-- Попередня перевірка рядка перед UPDATE
SELECT product_id, name, price, stock_quantity
FROM products
WHERE legacy_sku = 'SKU-ACC-002';

UPDATE products
SET price = 4199.00,
    stock_quantity = stock_quantity - 1
WHERE legacy_sku = 'SKU-ACC-002';

-- Перевірка результату після UPDATE
SELECT product_id, name, price, stock_quantity
FROM products
WHERE legacy_sku = 'SKU-ACC-002';

-- Запит 3.2: Оновлення статусу замовлення №5 з 'pending' на 'paid' та фіксація оплати в таблиці payments
UPDATE orders
SET status = 'paid'
WHERE order_id = 5 AND status = 'pending';

UPDATE payments
SET payment_status = 'completed',
    paid_at = '2026-10-05 16:30:00'
WHERE order_id = 5;

-- Перевірка оновленого замовлення №5 та його платежу
SELECT o.order_id, o.status AS order_status, p.payment_status, p.amount, p.paid_at
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_id = 5;

-- ============================================================================
-- ЧАСТИНА 4: БЕЗПЕЧНЕ ВИДАЛЕННЯ ДАНИХ (DELETE FROM ... WHERE) ТА ПЕРЕВІРКА
-- ============================================================================

-- Запит 4.1: Безпечне видалення тестової позиції та замовлення №7 (до його оплати)
-- Крок 1: Попередня перевірка через SELECT з тією ж умовою WHERE
SELECT order_id, product_id, product_name, quantity
FROM order_items
WHERE order_id = 7 AND product_id = 9;

-- Крок 2: Видалення позиції замовлення
DELETE FROM order_items
WHERE order_id = 7 AND product_id = 9;

-- Крок 3: Видалення самого неоплаченого замовлення №7
DELETE FROM orders
WHERE order_id = 7 AND status = 'pending';

-- Крок 4: Перевірка за допомогою SELECT, що замовлення №7 та його позиції видалені
SELECT order_id, customer_id, status, total_amount
FROM orders
WHERE order_id = 7;

