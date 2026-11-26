INSERT INTO categories (category_id, name, description) VALUES
    (1, 'Смартфони', 'Мобільні телефони та смартфони'),
    (2, 'Ноутбуки', 'Ноутбуки для роботи, навчання та ігор'),
    (3, 'Навушники', 'Дротові та бездротові навушники і гарнітури'),
    (4, 'Аксесуари', 'Зарядні пристрої, кабелі, павербанки');

INSERT INTO products (product_id, category_id, name, price, stock_quantity) VALUES
    (101, 1, 'iPhone 15 128GB', 34999.00, 12),
    (102, 1, 'Samsung Galaxy S24', 31500.00, 8),
    (103, 2, 'Lenovo IdeaPad Slim 5', 26800.00, 6),
    (104, 3, 'Sony WH-1000XM5', 14200.00, 10),
    (105, 4, 'Baseus GaN 65W Charger', 1250.00, 25);

INSERT INTO customers (customer_id, full_name, email, phone, shipping_address, created_at) VALUES
    (1, 'Олена Коваленко', 'olena.kovalenko@example.com', '+380501112233', 'м. Київ, вул. Січових Стрільців, 15', '2026-10-01 10:15:00'),
    (2, 'Максим Бондар', 'maksym.bondar@example.com', '+380672223344', 'м. Львів, вул. Городоцька, 42', '2026-10-03 14:20:00'),
    (3, 'Ірина Ткаченко', 'iryna.tkachenko@example.com', '+380633334455', 'м. Дніпро, просп. Дмитра Яворницького, 88', '2026-10-05 18:05:00'),
    (4, 'Денис Мельник', 'denys.melnyk@example.com', '+380934445566', 'м. Одеса, вул. Дерибасівська, 10', '2026-10-08 12:40:00');

INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
    (501, 1, '2026-10-10 11:00:00', 'paid', 36249.00),
    (502, 2, '2026-10-11 16:30:00', 'pending', 14200.00),
    (503, 1, '2026-10-12 09:45:00', 'shipped', 26800.00),
    (504, 3, '2026-10-13 20:10:00', 'cancelled', 31500.00);

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
    (1, 501, 101, 1, 34999.00),
    (2, 501, 105, 1, 1250.00),
    (3, 502, 104, 1, 14200.00),
    (4, 503, 103, 1, 26800.00),
    (5, 504, 102, 1, 31500.00);

INSERT INTO payments (payment_id, order_id, payment_date, payment_method, amount, payment_status) VALUES
    (901, 501, '2026-10-10 11:02:00', 'card', 36249.00, 'completed'),
    (902, 502, '2026-10-11 16:31:00', 'apple_pay', 14200.00, 'pending'),
    (903, 503, '2026-10-12 09:47:00', 'card', 26800.00, 'completed'),
    (904, 504, '2026-10-13 20:12:00', 'cash_on_delivery', 31500.00, 'failed');

SELECT setval(pg_get_serial_sequence('categories', 'category_id'), COALESCE((SELECT MAX(category_id) FROM categories), 1));
SELECT setval(pg_get_serial_sequence('products', 'product_id'), COALESCE((SELECT MAX(product_id) FROM products), 1));
SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), COALESCE((SELECT MAX(customer_id) FROM customers), 1));
SELECT setval(pg_get_serial_sequence('orders', 'order_id'), COALESCE((SELECT MAX(order_id) FROM orders), 1));
SELECT setval(pg_get_serial_sequence('order_items', 'order_item_id'), COALESCE((SELECT MAX(order_item_id) FROM order_items), 1));
SELECT setval(pg_get_serial_sequence('payments', 'payment_id'), COALESCE((SELECT MAX(payment_id) FROM payments), 1));

SELECT product_id, name, price, stock_quantity
FROM products;

SELECT product_id, name, price
FROM products
WHERE price > 20000;

SELECT customer_id, full_name, email, shipping_address
FROM customers
WHERE shipping_address LIKE '%Київ%';

SELECT order_id, customer_id, status, total_amount
FROM orders
WHERE total_amount > 25000;

SELECT order_id, status FROM orders WHERE order_id = 502;
SELECT payment_id, order_id, payment_status FROM payments WHERE order_id = 502;

UPDATE orders
SET status = 'paid'
WHERE order_id = 502;

UPDATE payments
SET payment_status = 'completed'
WHERE order_id = 502;

SELECT order_id, status FROM orders WHERE order_id = 502;
SELECT payment_id, order_id, payment_status FROM payments WHERE order_id = 502;

SELECT * FROM payments WHERE payment_id = 904;

DELETE FROM payments
WHERE payment_id = 904;

SELECT * FROM payments WHERE payment_id = 904;