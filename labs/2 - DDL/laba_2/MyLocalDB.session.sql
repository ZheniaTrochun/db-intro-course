DROP TABLE IF EXISTS order_product CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS payment_data CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20)
);
CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(customer_id) ON DELETE CASCADE,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL
);
CREATE TABLE payment_data (
    payment_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(customer_id) ON DELETE CASCADE,
    card_type VARCHAR(50) NOT NULL,
    card_number VARCHAR(20) NOT NULL,
    card_cvv VARCHAR(10) NOT NULL
);
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(customer_id),
    payment_data_id INTEGER REFERENCES payment_data(payment_id),
    shipping_address_id INTEGER REFERENCES address(address_id),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending'
);
CREATE TABLE order_product (
    order_product_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES product(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    fix_price DECIMAL(10, 2) NOT NULL CHECK (fix_price >= 0),
    country VARCHAR(100),
    shipping VARCHAR(255)
);
INSERT INTO customer (name, email, phone)
VALUES (
        'Олена Коваль',
        'olena.koval@gmail.com',
        '+380501234567'
    ),
    (
        'Максим Бойко',
        'maksym.b@ukr.net',
        '+380679876543'
    ),
    (
        'Анна Ткаченко',
        'anna.tk@gmail.com',
        '+380931112233'
    );
INSERT INTO address (customer_id, street, city, postal_code)
VALUES (1, 'вул. Хрещатик, 15, кв. 4', 'Київ', '01001'),
    (2, 'просп. Свободи, 7', 'Львів', '79000'),
    (
        3,
        'вул. Соборна, 22, кв. 10',
        'Вінниця',
        '21000'
    );
INSERT INTO payment_data (customer_id, card_type, card_number, card_cvv)
VALUES (1, 'Visa', '4111222233334444', '123'),
    (2, 'Mastercard', '5105111122223333', '456'),
    (3, 'Visa', '4242999988887777', '789');
INSERT INTO product (name, description, price, stock_quantity)
VALUES (
        'Механічна клавіатура',
        'RGB підсвітка, червоні світчі',
        2499.00,
        25
    ),
    (
        'Бездротова миша',
        'Оптичний сенсор 16000 DPI',
        1250.50,
        40
    ),
    (
        'Килимок для столу',
        'Тканинний килимок 900x400 мм',
        450.00,
        100
    ),
    (
        'Монітор 27 IPS',
        '2560x1440, 144Hz',
        8999.00,
        15
    );
INSERT INTO orders (
        customer_id,
        payment_data_id,
        shipping_address_id,
        order_date,
        status
    )
VALUES (1, 1, 1, '2026-09-20', 'Delivered'),
    (2, 2, 2, '2026-09-25', 'Processing'),
    (1, 1, 1, '2026-09-28', 'Pending');
INSERT INTO order_product (
        order_id,
        product_id,
        quantity,
        fix_price,
        country,
        shipping
    )
VALUES (1, 1, 1, 2499.00, 'Україна', 'Нова Пошта'),
    (1, 3, 2, 450.00, 'Україна', 'Нова Пошта'),
    (2, 4, 1, 8999.00, 'Україна', 'Самовивіз'),
    (3, 2, 1, 1250.50, 'Україна', 'Укрпошта');
SELECT *
FROM orders;
SELECT *
FROM order_product;
SELECT *
FROM customer;
SELECT *
FROM address;
SELECT *
FROM payment_data;
SELECT *
FROM product;
SELECT *
FROM orders;
SELECT *
FROM order_product;