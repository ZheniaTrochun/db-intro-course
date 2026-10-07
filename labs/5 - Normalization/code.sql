DROP TABLE IF EXISTS product_category;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS brand;
DROP TYPE IF EXISTS order_status_type;

CREATE TYPE order_status_type AS ENUM ('New', 'In Progress', 'Shipped', 'Delivered', 'Cancelled');
 
CREATE TABLE brand (
	brand_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	brand_title VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE category (
	category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category_title VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE customer (
	customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_first_name VARCHAR(100) NOT NULL,
	customer_last_name VARCHAR(100) NOT NULL,
	customer_email VARCHAR(100) NOT NULL UNIQUE,
	customer_phone_number VARCHAR(100) NOT NULL UNIQUE,
	customer_birth_date DATE NOT NULL
);
CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	brand_id INTEGER NOT NULL REFERENCES brand(brand_id),
    product_title VARCHAR(100) NOT NULL,
    product_price NUMERIC(8, 2) NOT NULL CHECK (product_price>0),
	product_expiration_date DATE,
    product_pao_months INTEGER,
	product_volume VARCHAR(50) NOT NULL,
	product_application_method TEXT
);
CREATE TABLE product_category (
	product_id INTEGER REFERENCES product(product_id),
	category_id INTEGER REFERENCES category(category_id),
	PRIMARY KEY (product_id, category_id)
);
CREATE TABLE orders (
	orders_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_id INTEGER REFERENCES customer(customer_id),
	orders_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
	orders_price NUMERIC(8, 2) NOT NULL CHECK (orders_price>0),
	orders_status order_status_type NOT NULL,
	orders_delivery_address TEXT NOT NULL
);
CREATE TABLE order_item (
	orders_id INTEGER REFERENCES orders(orders_id),
	product_id INTEGER REFERENCES product(product_id),
	quantity INTEGER NOT NULL,
	price NUMERIC(8, 2) NOT NULL CHECK (price>0),
	PRIMARY KEY (orders_id, product_id)
);
