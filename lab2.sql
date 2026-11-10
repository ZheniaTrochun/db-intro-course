DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS product_item CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS category CASCADE;

CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL
);
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES category(category_id) ON DELETE RESTRICT,
    product_name VARCHAR(150) NOT NULL,
    product_description TEXT,
    product_price NUMERIC(10, 2) NOT NULL CHECK (product_price >= 0)
);
CREATE TABLE product_item (
    product_item_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    product_item_size VARCHAR(20) NOT NULL,
    product_item_color VARCHAR(30) NOT NULL,
    product_item_stock_quantity INTEGER NOT NULL CHECK (product_item_stock_quantity >= 0)
);
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_price NUMERIC(10, 2) NOT NULL CHECK (order_price >= 0),
    order_status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (
        order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned')
    )
);
CREATE TABLE order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_item(product_item_id) ON DELETE RESTRICT,
    order_item_quantity INTEGER NOT NULL CHECK (order_item_quantity > 0),
    order_item_unit_price NUMERIC(10, 2) NOT NULL CHECK (order_item_unit_price >= 0)
);
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE REFERENCES "order"(order_id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_amount NUMERIC(10, 2) NOT NULL CHECK (payment_amount >= 0),
    payment_method VARCHAR(50) NOT NULL
);


INSERT INTO category (category_id, category_name) VALUES
    (1, 'Верхній одяг'),
    (2, 'Джинси та штани'),
    (3, 'Футболки та поло');
INSERT INTO customer (customer_id, first_name, last_name, email, phone) VALUES
    (1, 'Марта', 'Горічко', 'marta.gorichko@example.com', '+380501112233'),
    (2, 'Анна', 'Денісова', 'anna.denisova@example.com', '+380672223344'),
    (3, 'Тетяна', 'Денісова', 'tetiana.denisova@example.com', '+380933334455');
INSERT INTO product (product_id, category_id, product_name, product_description, product_price) VALUES
    (1, 1, 'Джинсова куртка Classic', 'Стильна куртка з деніму вільного крою', 1899.00),
    (2, 2, 'Джинси Slim Fit', 'Зручні повсякденні джинси', 1450.00),
    (3, 3, 'Базова футболка Basic', 'Бавовняна однотонна футболка', 499.00);
INSERT INTO product_item (product_item_id, product_id, product_item_size, product_item_color, product_item_stock_quantity) VALUES
    (1, 1, 'M', 'Синій', 15),
    (2, 1, 'L', 'Синій', 8),
    (3, 2, '32/32', 'Чорний', 12),
    (4, 3, 'S', 'Білий', 25),
    (5, 3, 'M', 'Білий', 30);
INSERT INTO "order" (order_id, customer_id, order_date, order_price, order_status) VALUES
    (101, 1, '2026-10-25 10:15:00', 2398.00, 'Processing'),
    (102, 2, '2026-10-26 14:30:00', 1450.00, 'Delivered'),
    (103, 3, '2026-10-28 09:00:00', 499.00, 'Pending');
INSERT INTO order_item (order_item_id, order_id, product_item_id, order_item_quantity, order_item_unit_price) VALUES
    (1, 101, 1, 1, 1899.00), 
    (2, 101, 4, 1, 499.00),
    (3, 102, 3, 1, 1450.00), 
    (4, 103, 5, 1, 499.00);  
INSERT INTO payment (payment_id, order_id, payment_date, payment_amount, payment_method) VALUES
    (1, 101, '2026-10-25 10:18:00', 2398.00, 'Apple Pay'),
    (2, 102, '2026-10-26 14:35:00', 1450.00, 'Credit Card');