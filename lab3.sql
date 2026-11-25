DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS product_item CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TYPE IF EXISTS order_status CASCADE;

CREATE TYPE order_status AS ENUM ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned');

CREATE TABLE category (
    category_id int generated always as identity primary key,
    category_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE customer (
    customer_id int generated always as identity primary key,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone varchar(20) NOT NULL
);
CREATE TABLE product (
    product_id int generated always as identity primary key,
    category_id int NOT NULL REFERENCES category(category_id),
    product_name VARCHAR(150) NOT NULL,
    product_description TEXT,
    product_price NUMERIC(10, 2) NOT NULL CHECK (product_price >= 0)
);
CREATE TABLE product_item (
    product_item_id int generated always as identity primary key,
    product_id int NOT NULL REFERENCES product(product_id),
    product_item_size VARCHAR(5) NOT NULL,
    product_item_color VARCHAR(20) NOT NULL,
    product_item_stock_quantity int NOT NULL CHECK (product_item_stock_quantity >= 0)
);
CREATE TABLE "order" (
    order_id int generated always as identity primary key,
    customer_id int NOT NULL REFERENCES customer(customer_id),
    order_date TIMESTAMP DEFAULT now(),
    order_price NUMERIC(10, 2) NOT NULL CHECK (order_price >= 0),
    order_status order_status not null
);
CREATE TABLE order_item (
    order_item_id int generated always as identity primary key,
    order_id int NOT NULL REFERENCES "order"(order_id),
    product_item_id int NOT NULL REFERENCES product_item(product_item_id),
    order_item_quantity int NOT NULL CHECK (order_item_quantity > 0),
    order_item_unit_price NUMERIC(10, 2) NOT NULL CHECK (order_item_unit_price >= 0)
);
CREATE TABLE payment (
    payment_id int generated always as identity primary key,
    order_id INTEGER NOT NULL REFERENCES "order"(order_id),
    payment_date TIMESTAMP DEFAULT now(),
    payment_amount NUMERIC(10, 2) NOT NULL CHECK (payment_amount >= 0),
    payment_method VARCHAR(50) NOT NULL
);


INSERT INTO category (category_name) VALUES
    ('Верхній одяг'),
    ('Джинси та штани'),
    ('Футболки та поло');

INSERT INTO customer (first_name, last_name, email, phone) VALUES
    ('Марта', 'Горічко', 'marta.gorichko@example.com', '+380501112233'),
    ('Анна', 'Денісова', 'anna.denisova@example.com', '+380672223344'),
    ('Тетяна', 'Денісова', 'tetiana.denisova@example.com', '+380933334455');

INSERT INTO product (category_id, product_name, product_description, product_price) VALUES
    (1, 'Джинсова куртка Classic', 'Стильна куртка з деніму вільного крою', 1899.00),
    (2, 'Джинси Slim Fit', 'Зручні повсякденні джинси', 1450.00),
    (3, 'Базова футболка Basic', 'Бавовняна однотонна футболка', 499.00);

INSERT INTO product_item (product_id, product_item_size, product_item_color, product_item_stock_quantity) VALUES
    (1, 'M', 'Синій', 15),
    (1, 'L', 'Синій', 8),
    (2, '32/32', 'Чорний', 12),
    (3, 'S', 'Білий', 25),
    (3, 'M', 'Білий', 30);

INSERT INTO "order" (customer_id, order_date, order_price, order_status) VALUES
    (1, '2026-10-25 10:15:00', 2398.00, 'Processing'),
    (2, '2026-10-26 14:30:00', 1450.00, 'Delivered'),
    (3, '2026-10-28 09:00:00', 499.00, 'Pending');

INSERT INTO order_item (order_id, product_item_id, order_item_quantity, order_item_unit_price) VALUES
    (1, 1, 1, 1899.00), 
    (1, 4, 1, 499.00),
    (2, 3, 1, 1450.00), 
    (3, 5, 1, 499.00);  

INSERT INTO payment (order_id, payment_date, payment_amount, payment_method) VALUES
    (1, '2026-10-25 10:18:00', 2398.00, 'Apple Pay'),
    (2, '2026-10-26 14:35:00', 1450.00, 'Credit Card');


-- SELECT * FROM category;
-- SELECT * FROM customer;
-- SELECT * FROM product;
-- SELECT * FROM product_item;
-- SELECT * FROM "order";
-- SELECT * FROM order_item;
-- SELECT * FROM payment;






--ЛАБА 3

-- 1.  SELECT 


--  Вибірка конкретних стовпців із таблиці клієнтів
SELECT first_name, last_name, email 
FROM customer;

-- Фільтрація товарів вартістю від 1000 грн
SELECT product_name, product_price 
FROM product 
WHERE product_price >= 1000;

-- Пошук замовлень у статусі обробки
SELECT order_id, customer_id, order_date, order_price, order_status 
FROM "order" 
WHERE order_status = 'Processing';



-- 2.  INSERT 


--  Додавання нової категорії
INSERT INTO category (category_name) 
VALUES ('Аксесуари');

-- Реєстрація нового клієнта
INSERT INTO customer (first_name, last_name, email, phone) 
VALUES ('Олександр', 'Петренко', 'oleksandr.petrenko@example.com', '+380634445566');

-- Додавання нового товару в створену категорію (category_id = 4)
INSERT INTO product (category_id, product_name, product_description, product_price) 
VALUES (4, 'Шкіряний ремінь Classic', 'Ремінь з натуральної шкіри', 650.00);

-- Додавання платежу для замовлення №3
INSERT INTO payment (order_id, payment_date, payment_amount, payment_method) 
VALUES (3, '2026-10-28 09:05:00', 499.00, 'Cash on Delivery');

-- Перевірка результатів вставки:
SELECT * FROM category;
SELECT * FROM customer;
SELECT * FROM product WHERE category_id = 4;
SELECT * FROM payment;



-- 3. UPDATE 


-- Попередня перевірка запису перед оновленням:
SELECT * FROM customer WHERE first_name = 'Олександр' AND last_name = 'Петренко';

-- Оновлення контактних даних клієнта
UPDATE customer 
SET email = 'oleksandr.new@example.com', phone = '+380995556677'
WHERE first_name = 'Олександр' AND last_name = 'Петренко';

-- Зміна ціни тестового товару
UPDATE product 
SET product_price = 699.00 
WHERE product_name = 'Шкіряний ремінь Classic';

-- Оновлення статусу оплаченого замовлення №3
UPDATE "order" 
SET order_status = 'Processing' 
WHERE order_id = 3;

-- Перевірка результатів оновлення:
SELECT * FROM customer WHERE first_name = 'Олександр';
SELECT * FROM product WHERE product_name = 'Шкіряний ремінь Classic';
SELECT * FROM "order" WHERE order_id = 3;



-- 4. DELETE 


-- Попередня перевірка рядка перед видаленням:
SELECT * FROM product WHERE product_name = 'Шкіряний ремінь Classic';

-- Видалення тестового товару 
DELETE FROM product 
WHERE product_name = 'Шкіряний ремінь Classic';

-- Перевірка стану таблиці після видалення:
SELECT * FROM product;


