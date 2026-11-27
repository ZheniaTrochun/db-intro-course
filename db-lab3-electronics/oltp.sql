-- Лабораторна робота №3: OLTP для інтернет-магазину електроніки
-- Перед запуском виконайте schema.sql з лабораторної №2 у цій самій БД.
-- Усі зміни демонстраційні: наприкінці виконується ROLLBACK.
SET search_path TO electronics_store, public;
BEGIN;

-- 1. SELECT: товари смартфонів дорожче 30 000 грн; лише потрібні поля.
SELECT p.product_id, p.name, p.brand, p.price
FROM products AS p
JOIN categories AS c ON c.category_id = p.category_id
WHERE c.name = 'Смартфони' AND p.price > 30000
ORDER BY p.price DESC;

-- 2. SELECT: замовлення зі статусом paid або shipped із сумою.
SELECT o.order_id, a.full_name AS customer, o.status,
       SUM(oi.quantity * oi.unit_price)::NUMERIC(12, 2) AS total
FROM customer_orders AS o
JOIN accounts AS a ON a.account_id = o.account_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('paid', 'shipped')
GROUP BY o.order_id, a.full_name, o.status
ORDER BY o.order_id;

-- 3. INSERT: тимчасово додаємо тестовий смартфон, повертаємо створений рядок.
INSERT INTO products (category_id, name, brand, model, price, stock_quantity)
SELECT c.category_id, 'Тестовий смартфон OLTP', 'Demo', 'OLTP-001', 1000.00, 2
FROM categories AS c
WHERE c.name = 'Смартфони'
RETURNING product_id, name, price, stock_quantity;

-- Перевірка INSERT.
SELECT product_id, name, price, stock_quantity
FROM products WHERE model = 'OLTP-001';

-- 4. UPDATE: змінюємо лише тестовий товар; попередньо його ID знаходимо за унікальною моделлю.
UPDATE products
SET price = 950.00, stock_quantity = 3
WHERE model = 'OLTP-001'
RETURNING product_id, name, price, stock_quantity;

-- Перевірка UPDATE.
SELECT product_id, name, price, stock_quantity
FROM products WHERE model = 'OLTP-001';

-- 5. DELETE: видаляємо тільки тестовий товар за його унікальною моделлю.
DELETE FROM products
WHERE model = 'OLTP-001'
RETURNING product_id, name;

-- Перевірка DELETE: очікується 0 рядків.
SELECT product_id, name FROM products WHERE model = 'OLTP-001';

-- Повертаємо БД до стану до лабораторного прикладу.
ROLLBACK;
