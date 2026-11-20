CREATE TABLE customer (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    registered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE category (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(180) NOT NULL,
    description TEXT,
    current_price NUMERIC(10,2) NOT NULL CHECK (current_price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

ALTER TABLE product
    ADD CONSTRAINT chk_product_stock_nonnegative
    CHECK (stock_quantity >= 0);

CREATE TABLE customer_order (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    ordered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'new'
        CHECK (status IN ('new', 'paid', 'shipped', 'delivered', 'cancelled')),
    delivery_address VARCHAR(255) NOT NULL,
    delivery_city VARCHAR(100) NOT NULL
);

CREATE TABLE order_item (
    order_id INTEGER NOT NULL REFERENCES customer_order(order_id),
    product_id INTEGER NOT NULL REFERENCES product(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE product_category (
    product_id INTEGER NOT NULL REFERENCES product(product_id),
    category_id INTEGER NOT NULL REFERENCES category(category_id),
    PRIMARY KEY (product_id, category_id)
);

CREATE TABLE payment (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES customer_order(order_id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    method VARCHAR(30) NOT NULL
        CHECK (method IN ('card', 'bank_transfer', 'cash_on_delivery')),
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('pending', 'failed', 'completed')),
    paid_at TIMESTAMPTZ,
    CHECK (status <> 'completed' OR paid_at IS NOT NULL)
);

CREATE TABLE shipment (
    shipment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE REFERENCES customer_order(order_id),
    carrier VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('created', 'shipped', 'delivered')),
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    CHECK (delivered_at IS NULL OR shipped_at IS NOT NULL),
    CHECK (delivered_at IS NULL OR delivered_at >= shipped_at),
    CHECK (status <> 'delivered' OR delivered_at IS NOT NULL)
);
