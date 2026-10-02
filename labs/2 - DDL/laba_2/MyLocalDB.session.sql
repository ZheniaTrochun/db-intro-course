DROP TABLE IF EXISTS order_product CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS payment_data CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL CONSTRAINT uq_customer_email UNIQUE,
    phone VARCHAR(20) NOT NULL,
    CONSTRAINT chk_email_format CHECK (email LIKE '%_@__%.__%')
);
CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'Україна',
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    CONSTRAINT fk_address_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT uq_address_customer UNIQUE (address_id, customer_id)
);
CREATE TABLE payment_data (
    payment_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    card_type VARCHAR(50) NOT NULL,
    card_mask VARCHAR(20) NOT NULL,
    expiration_date VARCHAR(5) NOT NULL,
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT uq_payment_customer UNIQUE (payment_id, customer_id),
    CONSTRAINT chk_card_mask CHECK (card_mask ~ '^(\*\*\*\* ){3}\d{4}$'),
    CONSTRAINT chk_expiration_format CHECK (expiration_date ~ '^(0[1-9]|1[0-2])\/\d{2}$'),
    CONSTRAINT chk_card_type CHECK (
        card_type IN (
            'Visa',
            'Mastercard'
        )
    )
);
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    CONSTRAINT chk_product_price CHECK (price > 0),
    CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0)
);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    payment_data_id INTEGER NOT NULL,
    shipping_address_id INTEGER NOT NULL,
    shipping_method VARCHAR(50) NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_orders_address_safe FOREIGN KEY (shipping_address_id, customer_id) REFERENCES address(address_id, customer_id),
    CONSTRAINT fk_orders_payment_safe FOREIGN KEY (payment_data_id, customer_id) REFERENCES payment_data(payment_id, customer_id),
    CONSTRAINT chk_order_status CHECK (
        status IN (
            'Pending',
            'Processing',
            'Shipped',
            'Delivered',
            'Cancelled'
        )
    ),
    CONSTRAINT chk_shipping_method CHECK (
        shipping_method IN ('Нова Пошта', 'Укрпошта', 'Самовивіз', 'Кур''єр')
    )
);
CREATE TABLE order_product (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_order_product PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_product_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_product_product FOREIGN KEY (product_id) REFERENCES product(product_id),
    CONSTRAINT chk_op_quantity CHECK (quantity > 0),
    CONSTRAINT chk_op_price CHECK (price_at_purchase >= 0)
);
CREATE INDEX idx_address_customer ON address(customer_id);
CREATE INDEX idx_payment_customer ON payment_data(customer_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_payment ON orders(payment_data_id);
CREATE INDEX idx_orders_address ON orders(shipping_address_id);
CREATE INDEX idx_order_product_product ON order_product(product_id);
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
INSERT INTO address (customer_id, country, street, city, postal_code)
VALUES (
        1,
        'Україна',
        'вул. Хрещатик, 15, кв. 4',
        'Київ',
        '01001'
    ),
    (
        2,
        'Україна',
        'просп. Свободи, 7',
        'Львів',
        '79000'
    ),
    (
        3,
        'Україна',
        'вул. Соборна, 22, кв. 10',
        'Вінниця',
        '21000'
    );
INSERT INTO payment_data (
        customer_id,
        card_type,
        card_mask,
        expiration_date
    )
VALUES (1, 'Visa', '**** **** **** 4444', '12/26'),
    (2, 'Mastercard', '**** **** **** 3333', '09/25'),
    (3, 'Visa', '**** **** **** 7777', '01/28');
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
        shipping_method,
        order_date,
        status
    )
VALUES (
        1,
        1,
        1,
        'Нова Пошта',
        '2026-09-20 14:30:00',
        'Delivered'
    ),
    (
        2,
        2,
        2,
        'Самовивіз',
        '2026-09-25 10:15:00',
        'Processing'
    ),
    (
        1,
        1,
        1,
        'Укрпошта',
        '2026-09-28 18:45:00',
        'Pending'
    );
INSERT INTO order_product (
        order_id,
        product_id,
        quantity,
        price_at_purchase
    )
VALUES (1, 1, 1, 2499.00),
    (1, 3, 2, 450.00),
    (2, 4, 1, 8999.00),
    (3, 2, 1, 1250.50);
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
SELECT o.order_id,
    c.name AS customer_name,
    p.name AS product_name,
    op.quantity,
    o.status
FROM orders o
    JOIN customer c ON o.customer_id = c.customer_id
    JOIN order_product op ON o.order_id = op.order_id
    JOIN product p ON op.product_id = p.product_id;