DROP TABLE IF EXISTS order_product, orders, payment_data, address, product, customer CASCADE;
DROP TYPE IF EXISTS card_type_enum, shipping_method_enum, order_status_enum CASCADE;

CREATE TYPE card_type_enum AS ENUM ('Visa', 'Mastercard');
CREATE TYPE shipping_method_enum AS ENUM ('Нова Пошта', 'Укрпошта', 'Самовивіз', 'Кур''єр');
CREATE TYPE order_status_enum AS ENUM ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled');

CREATE TABLE customer (
    customer_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    email          VARCHAR(255) NOT NULL
                   CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    password_hash  VARCHAR(255) NOT NULL, -- хешування на рівні бекенду
    phone          VARCHAR(20)  NOT NULL,
    deleted_at     TIMESTAMP NULL,
    is_active      BOOLEAN GENERATED ALWAYS AS (deleted_at IS NULL) STORED
);

CREATE UNIQUE INDEX uq_customer_email ON customer (lower(email)) WHERE deleted_at IS NULL;

CREATE TABLE address (
    address_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    country      VARCHAR(100) NOT NULL DEFAULT 'Україна' CHECK (country = 'Україна'),
    street       VARCHAR(255) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    postal_code  VARCHAR(20)  NOT NULL,
    is_default   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMP NULL,
    is_active    BOOLEAN GENERATED ALWAYS AS (deleted_at IS NULL) STORED,
    CONSTRAINT uq_address_customer UNIQUE (address_id, customer_id)
);

CREATE UNIQUE INDEX ux_address_one_default
    ON address (customer_id) WHERE is_default AND is_active;

CREATE TABLE payment_data (
    payment_data_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id      INTEGER NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    card_type        card_type_enum NOT NULL,
    card_mask        VARCHAR(20) NOT NULL
                     CHECK (card_mask ~ '^\*{4} \*{4} \*{4} [0-9]{4}$'),
    expiration_date  VARCHAR(5) NOT NULL
                     CHECK (expiration_date ~ '^(0[1-9]|1[0-2])/[0-9]{2}$'),
    is_default       BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at       TIMESTAMP NULL,
    is_active        BOOLEAN GENERATED ALWAYS AS (deleted_at IS NULL) STORED,
    CONSTRAINT uq_payment_customer UNIQUE (payment_data_id, customer_id)
);

CREATE UNIQUE INDEX ux_payment_one_default
    ON payment_data (customer_id) WHERE is_default AND is_active;

CREATE TABLE product (
    product_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    price           NUMERIC(12, 2) NOT NULL CHECK (price > 0),
    stock_quantity  INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    deleted_at      TIMESTAMP NULL,
    is_active       BOOLEAN GENERATED ALWAYS AS (deleted_at IS NULL) STORED
);

CREATE TABLE orders (
    order_id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id          INTEGER NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    payment_data_id      INTEGER NOT NULL,
    shipping_address_id  INTEGER NOT NULL,
    shipping_method      shipping_method_enum NOT NULL,
    order_date           TIMESTAMP NOT NULL DEFAULT NOW(),
    status               order_status_enum NOT NULL DEFAULT 'Pending',

    FOREIGN KEY (shipping_address_id, customer_id)
        REFERENCES address(address_id, customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (payment_data_id, customer_id)
        REFERENCES payment_data(payment_data_id, customer_id) ON DELETE RESTRICT
);

CREATE TABLE order_product (
    order_id           INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    product_id         INTEGER NOT NULL REFERENCES product(product_id) ON DELETE RESTRICT,
    quantity           INTEGER NOT NULL CHECK (quantity > 0),
    price_at_purchase  NUMERIC(12, 2) NOT NULL CHECK (price_at_purchase > 0),
    PRIMARY KEY (order_id, product_id) -- один товар = один рядок
);

INSERT INTO customer (name, email, password_hash, phone, deleted_at) VALUES
('Олена Коваленко',  'olena@example.com',  '$2b$12$hash_olena',  '+380501111111', NULL),
('Андрій Шевченко',  'andriy@example.com', '$2b$12$hash_andriy', '+380502222222', NULL),
('Марія Бондаренко', 'maria@example.com',  '$2b$12$hash_maria',  '+380503333333', NULL),
('Іван Мельник',     'ivan@example.com',   '$2b$12$hash_ivan',   '+380504444444', '2026-09-20 12:00:00');

INSERT INTO address (customer_id, city, street, postal_code, is_default, deleted_at) VALUES
(1, 'Київ',    'вул. Хрещатик, 1, кв. 10',   '01001', TRUE,  NULL),
(1, 'Львів',   'вул. Городоцька, 25',        '79000', FALSE, NULL),
(1, 'Одеса',   'вул. Дерибасівська, 5',      '65000', FALSE, '2026-08-15 10:00:00'),
(2, 'Харків',  'просп. Науки, 14, кв. 3',    '61000', TRUE,  NULL),
(3, 'Дніпро',  'вул. Яворницького, 7',       '49000', TRUE,  NULL),
(4, 'Полтава', 'вул. Соборності, 2',         '36000', FALSE, '2026-09-20 12:00:00');

INSERT INTO payment_data (customer_id, card_type, card_mask, expiration_date, is_default, deleted_at) VALUES
(1, 'Visa',       '**** **** **** 1111', '12/28', TRUE,  NULL),
(1, 'Mastercard', '**** **** **** 2222', '06/27', FALSE, NULL),
(1, 'Visa',       '**** **** **** 3333', '01/26', FALSE, '2026-08-15 10:00:00'),
(2, 'Mastercard', '**** **** **** 4444', '09/29', TRUE,  NULL),
(3, 'Visa',       '**** **** **** 5555', '03/30', TRUE,  NULL),
(4, 'Visa',       '**** **** **** 6666', '11/27', TRUE,  '2026-09-20 12:00:00');

INSERT INTO product (name, description, price, stock_quantity, deleted_at) VALUES
('Ноутбук ProBook 15',    'Ноутбук 15.6", 16 ГБ RAM, SSD 512 ГБ', 32999.99, 10, NULL),
('Мишка бездротова',      'Оптична мишка, USB-приймач',             499.50, 50, NULL),
('Клавіатура механічна',  'RGB-підсвітка, перемикачі Red',         1299.00,  0, NULL),
('Навушники Studio',      'Накладні, шумозаглушення',              2499.00, 25, NULL),
('Монітор 24" (старий)',  'Модель знято з виробництва',            3999.00,  3, '2026-07-01 09:00:00');

INSERT INTO orders (customer_id, shipping_address_id, payment_data_id, shipping_method, order_date, status) VALUES
(1, 1, 1, 'Нова Пошта', '2026-09-01 10:15:00', 'Delivered'),
(1, 3, 3, 'Укрпошта',   '2026-09-10 14:30:00', 'Shipped'),
(2, 4, 4, 'Самовивіз',  '2026-10-01 09:00:00', 'Processing'),
(4, 6, 6, 'Кур''єр',    '2026-09-05 16:45:00', 'Delivered'),
(3, 5, 5, 'Нова Пошта', '2026-10-10 11:20:00', 'Pending'),
(2, 4, 4, 'Нова Пошта', '2026-10-12 18:00:00', 'Cancelled');

INSERT INTO order_product (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 34999.99),
(1, 2, 2,   450.00),
(2, 4, 1,  2499.00),
(3, 2, 1,   499.50),
(3, 4, 2,  2499.00),
(4, 5, 1,  3999.00),
(5, 2, 3,   499.50),
(6, 3, 1,  1299.00);

SELECT * FROM customer ORDER BY customer_id;
SELECT * FROM address ORDER BY customer_id, address_id;
SELECT * FROM payment_data ORDER BY customer_id, payment_data_id;
SELECT * FROM product ORDER BY product_id;
SELECT * FROM orders ORDER BY order_id;
SELECT * FROM order_product ORDER BY order_id, product_id;

-- Тест 1: повторний email (регістр не має значення)

  --  INSERT INTO customer (name, email, password_hash, phone)
  --  VALUES ('Дубль', 'OLENA@example.com', 'x', '+380509999999');

 
-- Тест 2: некоректний формат email
 --   INSERT INTO customer (name, email, password_hash, phone)
   -- VALUES ('Тест', 'not-an-email', 'x', '+380509999998');

 
-- Тест 3: друга основна адреса в одного клієнта

  --  INSERT INTO address (customer_id, city, street, postal_code, is_default)
  --  VALUES (1, 'Вінниця', 'вул. Тестова, 1', '21000', TRUE);

 
-- Тест 4: повний номер картки замість маски (PCI DSS)

   -- INSERT INTO payment_data (customer_id, card_type, card_mask, expiration_date)
   -- VALUES (2, 'Visa', '4111111111111111', '05/29');
    
 
-- Тест 5: довільний статус замовлення

  --  UPDATE orders SET status = 'Lost' WHERE order_id = 1;

 
-- Тест 6: ціна товару 0 або -

   -- INSERT INTO product (name, price, stock_quantity) VALUES ('Безкоштовний', -9, 5);
 
-- Тест 7: від'ємний залишок

   -- INSERT INTO product (name, price, stock_quantity) VALUES ('Мінусовий', 100, -1);

 
-- Тест 8: замовлення на чужу адресу (клієнт 2, адреса id=1 належить клієнту 1)

--    INSERT INTO orders (customer_id, shipping_address_id, payment_data_id, shipping_method)
 --   VALUES (2, 1, 4, 'Нова Пошта');

 
-- Тест 9: замовлення з чужою карткою (клієнт 2, картка id=1 належить клієнту 1)

 --   INSERT INTO orders (customer_id, shipping_address_id, payment_data_id, shipping_method)
 --   VALUES (2, 4, 1, 'Нова Пошта');

 
-- Тест 10: недопустимий спосіб доставки

 --   INSERT INTO orders (customer_id, shipping_address_id, payment_data_id, shipping_method)
 --   VALUES (2, 4, 4, 'Дрон');

-- Тест 11: м'яке видалення

--UPDATE customer SET deleted_at = NOW() WHERE customer_id = 2; 
--UPDATE payment_data SET deleted_at = NOW() WHERE payment_data_id = 1 AND customer_id = 1; 
--UPDATE address SET deleted_at = NOW() WHERE address_id = 1 AND customer_id = 1;

--SELECT * FROM payment_data WHERE customer_id = 1 AND is_active = TRUE; 
--SELECT * FROM address WHERE customer_id = 1 AND is_active = TRUE;