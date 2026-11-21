-- customer
ALTER TABLE customer DROP COLUMN shipping_address_default;
ALTER TABLE customer ADD COLUMN default_address_id INT REFERENCES address(address_id) ON DELETE SET NULL;

-- orders
ALTER TABLE orders DROP COLUMN shipping_address;
ALTER TABLE orders DROP COLUMN total_amount;
ALTER TABLE orders ADD COLUMN shipping_address_id INT NOT NULL REFERENCES address(address_id) ON DELETE RESTRICT;

-- author
ALTER TABLE author ADD COLUMN country_id INT, ADD CONSTRAINT fk_author_country FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE RESTRICT;
ALTER TABLE author DROP COLUMN country;

-- publisher
ALTER TABLE publisher ADD COLUMN country_id INT, ADD CONSTRAINT fk_publisher_country FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE RESTRICT;
ALTER TABLE publisher DROP COLUMN country_publisher;

-- review
ALTER TABLE review DROP CONSTRAINT uq_customer_book_review;
ALTER TABLE review DROP COLUMN book_id;
ALTER TABLE review DROP CONSTRAINT review_order_item_id_fkey;
ALTER TABLE review ALTER COLUMN order_item_id SET NOT NULL;
ALTER TABLE review ADD CONSTRAINT review_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES order_item(order_item_id) ON DELETE CASCADE;
ALTER TABLE review ADD CONSTRAINT uq_customer_order_item UNIQUE (customer_id, order_item_id);

CREATE TABLE city (
    city_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE country (
    country_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    iso_code     CHAR(2)      NOT NULL UNIQUE CONSTRAINT chk_country_iso CHECK (iso_code ~ '^[A-Z]{2}$'),
    name_country VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE address (
    address_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id INT NOT NULL REFERENCES city(city_id) ON DELETE RESTRICT,
    street VARCHAR(150) NOT NULL,
    building VARCHAR(20) NOT NULL,
    apartment VARCHAR(20)
);

CREATE TABLE customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    registration_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    default_address_id INT REFERENCES address(address_id) ON DELETE SET NULL
);

CREATE TABLE orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status order_status NOT NULL DEFAULT 'Pending',
    shipping_address_id INT NOT NULL REFERENCES address(address_id) ON DELETE RESTRICT
);

CREATE TABLE author (
    author_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country_id INT,
    CONSTRAINT fk_author_country FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE RESTRICT
);

CREATE TABLE publisher (
    publisher_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_publisher VARCHAR(100) UNIQUE NOT NULL,
    country_id INT,
    CONSTRAINT fk_publisher_country FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE RESTRICT
);

CREATE TABLE category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_category VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE book (
    book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    publisher_id INT NOT NULL REFERENCES publisher(publisher_id) ON DELETE RESTRICT,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    publication_year SMALLINT NOT NULL CHECK (publication_year BETWEEN -2000 AND 2100),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity SMALLINT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

CREATE TABLE book_author (
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES author(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE book_category (
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES category(category_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, category_id)
);

CREATE TABLE order_item (
    order_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE RESTRICT,
    quantity SMALLINT NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMERIC(10,2) NOT NULL CHECK (price_at_purchase >= 0),
    CONSTRAINT uq_order_book UNIQUE (order_id, book_id)
);

CREATE TABLE review (
    review_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    order_item_id INT NOT NULL REFERENCES order_item(order_item_id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_order_item UNIQUE (customer_id, order_item_id)
);