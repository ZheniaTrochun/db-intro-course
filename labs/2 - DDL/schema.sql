-- Клієнти магазину.
CREATE TABLE customer (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    first_name VARCHAR(100) NOT NULL
        CHECK (btrim(first_name) <> ''),

    last_name VARCHAR(100) NOT NULL
        CHECK (btrim(last_name) <> ''),

    email VARCHAR(254) NOT NULL UNIQUE
        CHECK (btrim(email) <> ''),

    phone VARCHAR(30),

    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Адреси доставки клієнтів.
CREATE TABLE address (
    address_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    city VARCHAR(100) NOT NULL
        CHECK (btrim(city) <> ''),

    street VARCHAR(150) NOT NULL
        CHECK (btrim(street) <> ''),

    building VARCHAR(20) NOT NULL
        CHECK (btrim(building) <> ''),

    postal_code VARCHAR(20) NOT NULL
        CHECK (btrim(postal_code) <> ''),

    CONSTRAINT fk_address_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),

    CONSTRAINT uq_address_customer
        UNIQUE (address_id, customer_id)
);
-- Категорії товарів.
CREATE TABLE category (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE
        CHECK (btrim(name) <> ''),

    description TEXT
);

-- Товари магазину.
CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    category_id INTEGER NOT NULL,

    name VARCHAR(150) NOT NULL
        CHECK (btrim(name) <> ''),

    description TEXT,

    price NUMERIC(10, 2) NOT NULL
        CHECK (price > 0),

    stock_qty INTEGER NOT NULL DEFAULT 0
        CHECK (stock_qty >= 0),

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES category (category_id)
);

-- Замовлення клієнтів.
CREATE TABLE orders (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    address_id INTEGER NOT NULL,

    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(20) NOT NULL DEFAULT 'new'
        CHECK (status IN (
            'new', 'paid', 'shipped', 'delivered', 'cancelled'
        )),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),

    -- Адреса доставки має належати клієнту замовлення.
    CONSTRAINT fk_orders_address_customer
        FOREIGN KEY (address_id, customer_id)
        REFERENCES address (address_id, customer_id)
);

-- Товари, що входять до замовлення.
CREATE TABLE order_item (
    order_id INTEGER NOT NULL,

    product_id INTEGER NOT NULL,

    quantity INTEGER NOT NULL
        CHECK (quantity >= 1),

    unit_price NUMERIC(10, 2) NOT NULL
        CHECK (unit_price > 0),

    PRIMARY KEY (order_id, product_id),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES product (product_id)
);

-- Платежі за замовленнями.
CREATE TABLE payment (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id INTEGER NOT NULL,

    amount NUMERIC(10, 2) NOT NULL
        CHECK (amount > 0),

    method VARCHAR(20) NOT NULL
        CHECK (method IN ('card', 'bank_transfer', 'cash')),

    paid_at TIMESTAMP,

    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'successful', 'failed')),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    -- Час успішної оплати вказується лише для успішного платежу.
    CONSTRAINT chk_payment_paid_at
        CHECK (
            (status = 'successful' AND paid_at IS NOT NULL)
            OR
            (status IN ('pending', 'failed') AND paid_at IS NULL)
        )
);

-- Відгуки клієнтів про товари.
CREATE TABLE review (
    review_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INTEGER NOT NULL,

    product_id INTEGER NOT NULL,

    rating INTEGER NOT NULL
        CHECK (rating BETWEEN 1 AND 5),

    comment TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),

    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id)
        REFERENCES product (product_id),

    -- Один клієнт може залишити лише один відгук на один товар.
    CONSTRAINT uq_review_customer_product
        UNIQUE (customer_id, product_id)
);