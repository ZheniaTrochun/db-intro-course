DROP VIEW IF EXISTS v_address, v_orders CASCADE;
DROP TABLE IF EXISTS order_item, shipment, payment, orders, product, category, worker,
address, postal_location, carrier, client CASCADE;

DROP TYPE IF EXISTS role_name CASCADE;
DROP TYPE IF EXISTS status_name CASCADE;
DROP TYPE IF EXISTS stock_status_name CASCADE;
DROP TYPE IF EXISTS methods CASCADE;
DROP TYPE IF EXISTS payment_status_name CASCADE;

CREATE TABLE client (
    client_id    serial PRIMARY KEY,
    client_name  varchar(32) NOT NULL,
    last_name    varchar(32) NOT NULL,
    email        varchar(32) NOT NULL CHECK (email LIKE '%@%.%'),
    phone_number varchar(20)
);

CREATE TABLE postal_location (
    location_id serial PRIMARY KEY,
    country     varchar(32) NOT NULL,
    city        varchar(32) NOT NULL,
    postal_code varchar(32) NOT NULL,
    CONSTRAINT uq_postal_location UNIQUE (country, postal_code)
);

CREATE TABLE address (
    address_id  serial PRIMARY KEY,
    street      varchar(32) NOT NULL,
    location_id integer NOT NULL REFERENCES postal_location(location_id),
    client_id   integer NOT NULL REFERENCES client(client_id)
);

CREATE TYPE role_name AS ENUM ('admin', 'courier', 'operator', 'manager');
CREATE TABLE worker (
    worker_id    serial PRIMARY KEY,
    worker_role  role_name NOT NULL,
    first_name   varchar(32) NOT NULL,
    last_name    varchar(32) NOT NULL,
    phone_number varchar(13) UNIQUE
);

CREATE TYPE status_name AS ENUM ('confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');
CREATE TABLE orders (
    order_id    serial PRIMARY KEY,
    order_date  date NOT NULL DEFAULT CURRENT_DATE,
    order_price NUMERIC(10, 2) NOT NULL CHECK (order_price >= 0),
    status      status_name NOT NULL,
    discount    integer CHECK (discount >= 0 AND discount <= 100),
    address_id  integer NOT NULL REFERENCES address(address_id),
    worker_id   integer NOT NULL REFERENCES worker(worker_id)
);

CREATE TABLE category (
    category_id   serial PRIMARY KEY,
    category_name varchar(32) NOT NULL,
    description   varchar(255) NOT NULL
);

CREATE TYPE stock_status_name AS ENUM ('in stock', 'out of stock', 'coming soon');
CREATE TABLE product (
    product_id   serial PRIMARY KEY,
    product_name text NOT NULL,
    price        NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    quantity     integer NOT NULL CHECK (quantity >= 0),
    description  varchar(255) NOT NULL,
    stock_status stock_status_name NOT NULL,
    image_url    text,
    category_id  integer NOT NULL REFERENCES category(category_id),
    CHECK (stock_status != 'out of stock' OR quantity = 0)
);

CREATE TABLE order_item (
    order_item_id serial PRIMARY KEY,
    quantity      integer NOT NULL CHECK (quantity > 0),
    order_id      integer NOT NULL REFERENCES orders(order_id),
    product_id    integer NOT NULL REFERENCES product(product_id),
    CONSTRAINT unique_order_item UNIQUE (order_id, product_id)
);

CREATE TYPE methods AS ENUM ('by card', 'online', 'by cash on delivery');
CREATE TYPE payment_status_name AS ENUM ('paid', 'not paid');
CREATE TABLE payment (
    payment_id     serial PRIMARY KEY,
    payment_date   timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method methods NOT NULL,
    payment_status payment_status_name NOT NULL,
    price          NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    order_id       integer NOT NULL REFERENCES orders(order_id)
);

CREATE TABLE carrier (
    carrier_id   serial PRIMARY KEY,
    carrier_name varchar(64) NOT NULL UNIQUE
);

CREATE TABLE shipment (
    shipment_id     serial PRIMARY KEY,
    carrier_id      integer REFERENCES carrier(carrier_id),
    tracking_number text UNIQUE,
    shipment_status varchar(50) NOT NULL DEFAULT 'processing'
        CHECK (shipment_status IN ('processing', 'shipped', 'delivered', 'cancelled')),
    shipping_date   date,
    order_id        integer NOT NULL REFERENCES orders(order_id),
    worker_id       integer REFERENCES worker(worker_id)
);

-- Views для сумісності із запитами Лаб. 3–4
CREATE VIEW v_address AS
SELECT a.address_id, a.client_id, pl.
country, pl.city, a.street, pl.postal_code
FROM address a
JOIN postal_location pl ON pl.location_id = a.location_id;

CREATE VIEW v_orders AS
SELECT o.*, a.client_id
FROM orders o
JOIN address a ON a.address_id = o.address_id;

-- Тестові дані
INSERT INTO client (client_name, last_name, email, phone_number) VALUES
('Ivan', 'Petrenko', 'ivan.petrenko@example.com', '+380501234567'),
('Olga', 'Shevchenko', 'olga.shev@example.com', '+380671112233'),
('Maksym', 'Bondar', 'maks.bondar@example.com', '+380931234567'),
('Anna', 'Kowalska', 'anna.kowalska@example.com', '+48501122334'),
('Peter', 'Schmidt', 'peter.schmidt@example.com', '+4915112345678');

INSERT INTO postal_location (country, city, postal_code) VALUES
('Ukraine', 'Kyiv', '01001'),
('Ukraine', 'Lviv', '79000'),
('Ukraine', 'Odessa', '65000'),
('Poland', 'Warsaw', '00-001'),
('Germany', 'Berlin', '10178');

INSERT INTO address (street, location_id, client_id) VALUES
('Shevchenka 12', 1, 1),
('Franko 3', 2, 2),
('Deribasivska 15', 3, 3),
('Krakowska 8', 4, 4),
('Alexanderplatz 1', 5, 5);

INSERT INTO category (category_name, description) VALUES
('Electronics', 'Devices and gadgets'),
('Clothing', 'Men and women apparel'),
('Home', 'Home and kitchen appliances'),
('Books', 'Printed and digital books'),
('Sports', 'Sports and outdoor equipment');

INSERT INTO worker (worker_role, first_name, last_name, phone_number) VALUES
('admin', 'Dmytro', 'Koval', '+380501111111'),
('manager', 'Kateryna', 'Hrytsenko', '+380672222222'),
('operator', 'Oleh', 'Melnyk', '+380933333333'),
('courier', 'Serhii', 'Tkachenko', '+380504444444'),
('courier', 'Maria', 'Lytvyn', '+380505555555');

INSERT INTO product (product_name, price, quantity, description, stock_status, image_url, category_id) VALUES
('Смартфон "Galaxy S30"', 29999.00, 50, 'Флагманський смартфон з покращеною камерою', 'in stock', 'https://example.com/images/galaxy-s30.png', 1),
('Ноутбук "ThinkPad X2"', 45000.00, 25, 'Потужний ноутбук для бізнесу', 'in stock', 'https://example.com/images/thinkpad-x2.png', 1),
('Бездротові навушники "AirSounds"', 4200.00, 0, 'Навушники з активним шумозаглушенням', 'out of stock', 'https://example.com/images/airsounds.png', 1);

INSERT INTO orders (order_date, order_price, status, discount, address_id, worker_id) VALUES
('2025-10-01', 12400.00, 'confirmed', 5, 1, 1),
('2025-10-02', 800.00, 'processing', 0, 2, 2),
('2025-10-03', 1750.00, 'shipped', 10, 3, 3),
('2025-10-04', 250.00, 'delivered', 0, 4, 4),
('2025-10-05', 36000.00, 'confirmed', 15, 5, 5);

INSERT INTO payment (payment_method, payment_status, price, order_id) VALUES
('by card', 'paid', 12400.00, 1),
('by card', 'not paid', 800.00, 2),
('by card', 'paid', 1750.00, 3),
('by card', 'paid', 250.00, 4),
('by card', 'paid', 36000.00, 5);

INSERT INTO carrier (carrier_name) VALUES
('Нова Пошта'),
('Укрпошта'),
('Meest');

INSERT INTO shipment (carrier_id, tracking_number, shipment_status, shipping_date, order_id, worker_id) VALUES
(1, '20450123456789', 'shipped', '2025-10-13', 4, 1);

INSERT INTO order_item (quantity, order_id, product_id) VALUES
(1, 5, 1),
(2, 4, 2),
(5, 3, 3),
(4, 2, 2),
(1, 1, 1);

-- Перевірка зв'язків та сумісності
SELECT o.order_id, c.client_name, pl.city
FROM orders o
JOIN address a ON a.address_id = o.address_id
JOIN client c ON c.client_id = a.client_id
JOIN postal_location pl ON pl.location_id = a.location_id;

SELECT s.shipment_id, s.tracking_number, ca.carrier_name, a.street, pl.city, pl.country
FROM shipment s
JOIN carrier ca ON ca.carrier_id = s.carrier_id
JOIN orders o ON o.order_id = s.order_id
JOIN address a ON a.address_id = o.address_id
JOIN postal_location pl ON pl.location_id = a.location_id;

SELECT payment_method, SUM(price) AS revenue
FROM payment
GROUP BY payment_method;

SELECT c.client_id, c.client_name, SUM(o.order_price) AS total_spent
FROM client c
LEFT JOIN v_orders o ON c.client_id = o.client_id
GROUP BY c.client_id, c.client_name
HAVING SUM(o.order_price) > 5000;