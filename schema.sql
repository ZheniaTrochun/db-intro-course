CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL,
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    name VARCHAR(120) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount > 0)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity >= 1),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN ('card', 'cash_on_delivery', 'apple_pay')),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'completed', 'failed'))
);

INSERT INTO customers (full_name, email, phone, shipping_address) VALUES
    ('Олександр Петренко', 'o.petrenko@example.com', '+380501112233', 'м. Київ, вул. Хрещатик, 15, кв. 42'),
    ('Марія Коваленко', 'm.kovalenko@example.com', '+380672223344', 'м. Львів, вул. Городоцька, 120'),
    ('Андрій Шевченко', 'a.shevchenko@example.com', '+380933334455', 'м. Одеса, вул. Дерибасівська, 5'),
    ('Юлія Бондаренко', 'y.bondarenko@example.com', '+380504445566', 'м. Харків, пр. Науки, 24'),
    ('Дмитро Мельник', 'd.melnyk@example.com', '+380635556677', 'м. Дніпро, вул. Дмитра Яворницького, 50');

INSERT INTO categories (name, description) VALUES
    ('Смартфони', 'Мобільні телефони та смартфони'),
    ('Навушники', 'Провідні та бездротові навушники й гарнітури'),
    ('Ноутбуки', 'Портативні комп''ютери для роботи, навчання та ігор'),
    ('Аксесуари', 'Захисні скла, чохли, кабелі та зарядні пристрої');

INSERT INTO products (category_id, name, price, stock_quantity) VALUES
    (1, 'Apple iPhone 15 128GB', 37999.00, 15),
    (1, 'Samsung Galaxy S24 256GB', 34999.00, 10),
    (2, 'Sony WH-1000XM5', 14999.00, 8),
    (3, 'Apple MacBook Air 13" M1', 42999.00, 5),
    (4, 'Захисне скло для iPhone 15', 499.00, 50);

INSERT INTO orders (customer_id, status, total_amount) VALUES
    (1, 'paid', 38498.00),
    (2, 'shipped', 14999.00),
    (3, 'pending', 34999.00),
    (4, 'delivered', 42999.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 37999.00),
    (1, 5, 1, 499.00),
    (2, 3, 1, 14999.00),
    (3, 2, 1, 34999.00),
    (4, 4, 1, 42999.00);

INSERT INTO payments (order_id, payment_method, amount, payment_status) VALUES
    (1, 'card', 38498.00, 'completed'),
    (2, 'apple_pay', 14999.00, 'completed'),
    (3, 'card', 34999.00, 'pending'),
    (4, 'card', 42999.00, 'completed');

SELECT * FROM customers;
SELECT * FROM categories;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;
