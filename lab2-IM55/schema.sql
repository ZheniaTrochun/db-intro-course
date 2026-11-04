CREATE TABLE author (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL
);

CREATE TABLE customer (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE category (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE address (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
	FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE
);

CREATE TABLE book (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id INTEGER NOT NULL REFERENCES author(id),
    title VARCHAR(200) NOT NULL,
    published_year INTEGER CHECK (published_year > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE book_category (
    book_id INTEGER NOT NULL REFERENCES book(id),
    category_id INTEGER NOT NULL REFERENCES category(id),
    PRIMARY KEY (book_id, category_id)
);

CREATE TABLE orders (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE RESTRICT,
    address_id INTEGER NOT NULL REFERENCES address(id) ON DELETE RESTRICT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'нове'
        CHECK (status IN ('нове', 'збирається', 'відправлено', 'отримано', 'скасовано'))
);

CREATE TABLE order_item (
    order_id INTEGER NOT NULL REFERENCES orders(id),
    book_id INTEGER NOT NULL REFERENCES book(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0 AND quantity <= 10),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, book_id)
);

CREATE TABLE payment (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE REFERENCES orders(id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    method VARCHAR(20) NOT NULL CHECK (method IN ('картка', 'готівка')),
    status VARCHAR(20) NOT NULL DEFAULT 'очікує' CHECK (status IN ('очікує', 'оплачено'))
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_address_id ON orders(address_id);

INSERT INTO author (first_name, last_name) VALUES
    ('Джоан', 'Роулінг'),
    ('Чак', 'Поланік'),
    ('Стівен', 'Кінг'),
    ('Ліна', 'Костенко'),
    ('Тарас', 'Шевченко'),
    ('Агата', 'Крісті'),
    ('Г. Д.', 'Карлтон');

INSERT INTO category (category_name) VALUES
    ('Фентезі'),
    ('Детектив'),
    ('Жахи'),
    ('Поезія'),
    ('Наукова фантастика'),
    ('Трилер'),
    ('Романтика');

INSERT INTO book (author_id, title, published_year, price) VALUES
    (1, 'Гаррі Поттер і філософський камінь', 1997, 350.00),
    (2, 'Бійцівський клуб', 1996, 300.00),
    (3, 'Воно', 1986, 420.00),
    (4, 'Маруся Чурай', 1979, 200.00),
    (5, 'Кобзар', 1840, 180.00),
    (6, 'Вбивство у Східному експресі', 1934, 260.00),
    (7, 'Переслідування Аделіни', 2021, 430.00);

INSERT INTO book_category (book_id, category_id) VALUES
    (1, 1), (2, 6), (3, 3), (3, 6), (4, 4),
    (5, 4), (6, 2), (7, 6), (7, 7);
    
INSERT INTO customer (first_name, last_name, email, phone) VALUES
    ('Олена', 'Іваненко', 'diva@gmail.com', '+380501112233'),
    ('Марк', 'Цукерберг', 'zuckerbergpromax@gmail.com', '+380671234567'),
    ('Софія', 'Ковальчук', 'sofiabondarenko1999@gmail.com', '+380931234567'),
    ('Артем', 'Пивоваров', 'hornyboy@gmail.com', '+380971234567'),
    ('Дарина', 'Бойко', 'slay@gmail.com', '+380631234567');
 
INSERT INTO address (customer_id, country, city, street, postal_code) VALUES
    (1, 'Україна', 'Київ', 'вул. Борщагівська 14', '01067'),
    (1, 'Україна', 'Київ', 'просп. Берестейський 25', '03257'),
    (2, 'США', 'Нью-Йорк', 'вул. Зодчих 5', '79722'),
    (3, 'Україна', 'Одеса', 'вул. Дерибасівська 12', '65900'),
    (4, 'Україна', 'Харків', 'вул. Соборна 3А', '11330'),
    (5, 'Україна', 'Житомир', 'просп. Перемоги 2', '49008');

INSERT INTO orders (customer_id, address_id, date, status) VALUES
    (1, 1, '2025-09-01', 'отримано'),
    (1, 2, '2025-09-15', 'відправлено'),
    (2, 3, '2025-09-20', 'збирається'),
    (3, 4, '2025-10-01', 'нове'),
    (4, 5, '2025-10-03', 'скасовано');

INSERT INTO order_item (order_id, book_id, quantity, unit_price) VALUES
    (1, 1, 1, 350.00),
    (2, 2, 2, 300.00),
    (3, 4, 1, 200.00),
    (4, 6, 1, 260.00),
    (5, 7, 2, 430.00);

INSERT INTO payment (order_id, amount, date, method, status) VALUES
    (1, 350.00, '2025-09-02', 'картка', 'оплачено'),
    (2, 600.00, '2025-09-16', 'готівка', 'оплачено'),
    (3, 200.00, '2025-09-20', 'картка', 'очікує'),
    (4, 260.00, '2025-10-01', 'готівка', 'очікує'),
    (5, 860.00, '2025-10-03', 'картка', 'очікує');
