-- 1. Додавання клієнтів
INSERT INTO customers (first_name, last_name, email, phone_number) VALUES
('Олександр', 'Коваленко', 'o.kovalenko@example.com', '+380671112233'),
('Марія', 'Шевченко', 'm.shevchenko@example.com', '+380502223344'),
('Дмитро', 'Бондаренко', 'd.bondarenko@example.com', '+380633334455'),
('Анна', 'Ткаченко', 'a.tkachenko@example.com', '+380974445566'),
('Ігор', 'Мельник', 'i.melnyk@example.com', '+380935556677');

-- 2. Додавання категорій
INSERT INTO categories (category_name) VALUES
('Ноутбуки та комп''ютери'),
('Смартфони та планшети'),
('Периферія та аксесуари'),
('Монітори'),
('Мережеве обладнання');

-- 3. Додавання товарів
INSERT INTO products (name, price, stock_quantity, category_id) VALUES
('Ноутбук ASUS VivoBook 15', 24999.00, 12, 1),
('Смартфон Samsung Galaxy A55', 16499.00, 25, 2),
('Бездротова миша Logitech MX Master 3S', 4299.00, 30, 3),
('Монітор Dell 27" IPS QHD', 11500.00, 8, 4),
('Wi-Fi роутер TP-Link Archer AX55', 2899.00, 18, 5);

-- 4. Додавання замовлень
INSERT INTO orders (order_date, status, customer_id) VALUES
('2026-11-20 10:15:00', 'Доставлено', 1),
('2026-11-21 14:30:00', 'Відправлено', 2),
('2026-11-23 09:45:00', 'В обробці', 1),
('2026-11-25 18:10:00', 'Нове', 3),
('2026-11-26 12:00:00', 'Нове', 4);

-- 5. Додавання деталей замовлень
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 24999.00),
(1, 3, 1, 4299.00),
(2, 2, 1, 16499.00),
(3, 4, 2, 11500.00),
(4, 5, 1, 2899.00),
(5, 3, 2, 4299.00);

-- Контрольна перевірка завантажених даних
SELECT * FROM customers;
SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;