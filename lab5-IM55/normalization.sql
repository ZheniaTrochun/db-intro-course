DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS book_category;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS author;

-- author - без змін
CREATE TABLE author (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);
-- customer - без змін
CREATE TABLE customer (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE
);

-- category - без змін
CREATE TABLE category (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(60) NOT NULL UNIQUE
);

-- address - без змін (country і city - незалежні частини адреси: назва міста не визначає країну однозначно, тому транзитивної залежності немає)
CREATE TABLE address (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20)
);

-- book, book_category - без змін
CREATE TABLE book (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id INT NOT NULL REFERENCES author(id),
    title VARCHAR(200) NOT NULL,
    published_year INT CHECK (published_year > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE book_category (
    book_id INT NOT NULL REFERENCES book(id),
    category_id INT NOT NULL REFERENCES category(id),
    PRIMARY KEY (book_id, category_id)
);

-- orders - змінена (видалено customer_id); причина: транзитивна залежність id -> address_id -> customer_id
CREATE TABLE orders (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address_id INT NOT NULL REFERENCES address(id) ON DELETE RESTRICT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'нове'
        CHECK (status IN ('нове', 'збирається', 'відправлено', 'отримано', 'скасовано'))
);

-- order_item, payment - без змін
CREATE TABLE order_item (
    order_id INT NOT NULL REFERENCES orders(id),
    book_id INT NOT NULL REFERENCES book(id),
    quantity INT NOT NULL CHECK (quantity > 0 AND quantity <= 10),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, book_id)
);

CREATE TABLE payment (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL UNIQUE REFERENCES orders(id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    method VARCHAR(20) NOT NULL CHECK (method IN ('картка', 'готівка')),
    status VARCHAR(20) NOT NULL DEFAULT 'очікує' CHECK (status IN ('очікує', 'оплачено'))
);


-- Тестові дані

INSERT INTO author (first_name, last_name) VALUES
    ('Джоан', 'Роулінг'),
    ('Чак', 'Поланік'),
    ('Стівен', 'Кінг'),
    ('Ліна', 'Костенко'),
    ('Тарас', 'Шевченко'),
    ('Агата', 'Крісті'),
    ('Г. Д.', 'Карлтон');

INSERT INTO category (category_name) VALUES
    ('Фентезі'),
    ('Детектив'),
    ('Жахи'),
    ('Поезія'),
    ('Наукова фантастика'),
    ('Трилер'),
    ('Романтика');

INSERT INTO book (author_id, title, published_year, price) VALUES
    (1, 'Гаррі Поттер і філософський камінь', 1997, 350.00),
    (2, 'Бійцівський клуб', 1996, 300.00),
    (3, 'Воно', 1986, 420.00),
    (4, 'Маруся Чурай', 1979, 200.00),
    (5, 'Кобзар', 1840, 180.00),
    (6, 'Вбивство у Східному експресі', 1934, 260.00),
    (7, 'Переслідування Аделіни', 2021, 430.00);

INSERT INTO book_category (book_id, category_id) VALUES
    (1, 1), (2, 6), (3, 3), (3, 6), (4, 4),
    (5, 4), (6, 2), (7, 6), (7, 7);

INSERT INTO customer (first_name, last_name, email, phone) VALUES
    ('Олена', 'Іваненко', 'diva@gmail.com', '+380501112233'),
    ('Марк', 'Цукерберг', 'zuckerbergpromax@gmail.com', '+380671234567'),
    ('Софія', 'Ковальчук', 'sofiabondarenko1999@gmail.com', '+380931234567'),
    ('Артем', 'Пивоваров', 'hornyboy@gmail.com', '+380971234567'),
    ('Дарина', 'Бойко', 'slay@gmail.com', '+380631234567');

INSERT INTO address (customer_id, country, city, street, postal_code) VALUES
    (1, 'Україна', 'Київ', 'вул. Борщагівська 14', '01067'),
    (1, 'Україна', 'Київ', 'просп. Берестейський 25', '03257'),
    (2, 'США', 'Нью-Йорк', 'вул. Зодчих 5', '79722'),
    (3, 'Україна', 'Одеса', 'вул. Дерибасівська 12', '65900'),
    (4, 'Україна', 'Харків', 'вул. Соборна 3А', '11330'),
    (5, 'Україна', 'Житомир', 'просп. Перемоги 2', '49008');

-- customer_id більше не вказуємо, бо його визначає адреса
INSERT INTO orders (address_id, date, status) VALUES
    (1, '2025-09-01', 'отримано'),
    (2, '2025-09-15', 'відправлено'),
    (3, '2025-09-20', 'збирається'),
    (4, '2025-10-01', 'нове'),
    (5, '2025-10-03', 'скасовано');

INSERT INTO order_item (order_id, book_id, quantity, unit_price) VALUES
    (1, 1, 1, 350.00),
    (2, 2, 2, 300.00),
    (3, 4, 1, 200.00),
    (4, 6, 1, 260.00),
    (5, 7, 2, 430.00);

INSERT INTO payment (order_id, amount, date, method, status) VALUES
    (1, 350.00, '2025-09-02', 'картка', 'оплачено'),
    (2, 600.00, '2025-09-16', 'готівка', 'оплачено'),
    (3, 200.00, '2025-09-20', 'картка', 'очікує'),
    (4, 260.00, '2025-10-01', 'готівка', 'очікує'),
    (5, 860.00, '2025-10-03', 'картка', 'очікує');


-- Запити лаб3–4, які довелося переписати (тут лише запити, що використовували orders.customer_id)
-- Решта запитів лаб3–4 працює без змін

-- Лобода Аліна
-- INSERT:
INSERT INTO orders (address_id)
VALUES (6);

-- UPDATE:
UPDATE orders
SET status = 'збирається'
WHERE status = 'нове'
  AND address_id IN (SELECT id FROM address WHERE customer_id = 5);

-- DELETE:
DELETE FROM orders
WHERE address_id IN (SELECT id FROM address WHERE customer_id = 5);

-- Варенко Катерина
-- 1.4
SELECT a.customer_id, COUNT(*) AS order_count
FROM orders o
JOIN address a ON a.id = o.address_id
WHERE a.customer_id IN (
    SELECT a2.customer_id
    FROM orders o2
    JOIN address a2 ON a2.id = o2.address_id
    GROUP BY a2.customer_id
    HAVING COUNT(*) > 1
)
GROUP BY a.customer_id
ORDER BY order_count DESC;

-- Лобода Аліна
-- 3.3
SELECT o.id AS order_id, o.date, o.status,
       c.first_name || ' ' || c.last_name AS customer,
       a.city, p.amount, p.method
FROM orders o
INNER JOIN address a ON a.id = o.address_id
INNER JOIN payment p ON p.order_id = o.id
LEFT JOIN customer c ON c.id = a.customer_id
ORDER BY o.id;

-- 3.4
SELECT o.id, a.customer_id, o.date, o.status
FROM orders o
JOIN address a ON a.id = o.address_id
WHERE o.id IN (
    SELECT order_id
    FROM payment
    WHERE status = 'очікує'
)
ORDER BY o.id;