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