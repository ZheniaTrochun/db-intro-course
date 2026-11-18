-- ============================================================================
-- Лабораторна робота №5: Нормалізація бази даних 
-- Предметна область: Інтернет-магазин електроніки «TechStore»
-- Виконала: Лінчевська Анастасія, група ІМ-о51
-- ============================================================================

-- Видалення попередніх таблиць у зворотному порядку залежностей
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS shipping_cities CASCADE;
DROP TABLE IF EXISTS product_tags CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================================================
-- ЧАСТИНА 1: СТВОРЕННЯ НОРМАЛІЗОВАНИХ ТАБЛИЦЬ У 3NF (CREATE TABLE)
-- ============================================================================

-- 1. Таблиця клієнтів (customers — 3NF)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name   VARCHAR(120) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(30)  NOT NULL UNIQUE,
    city        VARCHAR(80)  NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблиця категорій товарів (categories — 3NF)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 3. Таблиця постачальників (suppliers — виділена під час приведення до 3NF)
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name        VARCHAR(120) NOT NULL UNIQUE,
    phone       VARCHAR(30)  NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE
);

-- 4. Таблиця товарів (products — приведена до 1NF та 3NF)
CREATE TABLE products (
    product_id     SERIAL PRIMARY KEY,
    category_id    INTEGER       NOT NULL REFERENCES categories(category_id),
    supplier_id    INTEGER       NOT NULL REFERENCES suppliers(supplier_id),
    name           VARCHAR(150)  NOT NULL,
    legacy_sku     VARCHAR(50)   UNIQUE,
    price          NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INTEGER       NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

-- 5. Таблиця тегів товарів (product_tags — виділена під час приведення до 1NF)
CREATE TABLE product_tags (
    product_id INTEGER     NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    tag_name   VARCHAR(50) NOT NULL,
    PRIMARY KEY (product_id, tag_name)
);

-- 6. Довідникова таблиця міст та тарифів доставки (shipping_cities — виділена для 3NF)
CREATE TABLE shipping_cities (
    city_id         SERIAL PRIMARY KEY,
    city_name       VARCHAR(80)  NOT NULL UNIQUE,
    delivery_tariff NUMERIC(8,2) NOT NULL DEFAULT 0.00 CHECK (delivery_tariff >= 0)
);

-- 7. Таблиця замовлень (orders — приведена до 3NF)
CREATE TABLE orders (
    order_id         SERIAL PRIMARY KEY,
    customer_id      INTEGER       NOT NULL REFERENCES customers(customer_id),
    shipping_city_id INTEGER       NOT NULL REFERENCES shipping_cities(city_id),
    order_date       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           VARCHAR(30)   NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending', 'paid', 'shipped', 'completed', 'cancelled')),
    shipping_address VARCHAR(255)  NOT NULL,
    total_amount     NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

-- 8. Таблиця позицій замовлення (order_items — приведена до 2NF та 3NF без product_name)
CREATE TABLE order_items (
    order_id   INTEGER       NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER       NOT NULL REFERENCES products(product_id),
    quantity   INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)
);

-- 9. Таблиця платежів (payments — 3NF)
CREATE TABLE payments (
    payment_id     SERIAL PRIMARY KEY,
    order_id       INTEGER       NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(40)   NOT NULL
                   CHECK (payment_method IN ('card', 'apple_pay', 'google_pay', 'cash_on_delivery')),
    amount         NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_status VARCHAR(30)   NOT NULL DEFAULT 'pending'
                   CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    paid_at        TIMESTAMP
);

-- ============================================================================
-- ЧАСТИНА 2: ПЕРЕЗАВАНТАЖЕННЯ ЗРАЗКІВ ДАНИХ У НОРМАЛІЗОВАНУ СХЕМУ (INSERT INTO)
-- ============================================================================

INSERT INTO customers (full_name, email, phone, city, created_at) VALUES
    ('Олександр Коваленко', 'o.kovalenko@gmail.com',  '+380501112233', 'Київ',   '2026-09-01 10:15:00'),
    ('Марія Шевченко',      'm.shevchenko@ukr.net',   '+380672223344', 'Львів',  '2026-09-03 14:20:00'),
    ('Дмитро Бондаренко',   'd.bondarenko@gmail.com', '+380633334455', 'Київ',   '2026-09-05 18:45:00'),
    ('Ірина Мельник',       'i.melnyk@outlook.com',   '+380974445566', 'Одеса',  '2026-09-10 09:30:00'),
    ('Андрій Ткаченко',     'a.tkachenko@gmail.com',  '+380935556677', 'Дніпро', '2026-09-12 16:10:00'),
    ('Наталія Кравченко',   'n.kravchenko@ukr.net',   '+380506667788', 'Львів',  '2026-09-15 11:05:00');

INSERT INTO categories (name, description) VALUES
    ('Ноутбуки',               'Портативні комп''ютери для роботи, навчання та геймінгу'),
    ('Смартфони',              'Мобільні телефони та флагманські смартфони'),
    ('Аудіотехніка',           'Бездротові навушники, гарнітури та портативна акустика'),
    ('Монітори',               'Професійні, офісні та ігрові монітори високої чіткості'),
    ('Аксесуари та периферія', 'Клавіатури, миші, зарядні пристрої та кабелі');

INSERT INTO suppliers (name, phone, email) VALUES
    ('ТОВ ТехноІмпорт',      '+380442001010', 'supply@technoimport.ua'),
    ('ТОВ ЕплДистрибуція',   '+380443002020', 'b2b@appledist.ua'),
    ('ТОВ СамітЕлектронікс', '+380444003030', 'orders@summit-elec.ua'),
    ('ТОВ СаундПро',         '+380445004040', 'sales@soundpro.ua');

INSERT INTO products (category_id, supplier_id, name, legacy_sku, price, stock_quantity) VALUES
    (1, 1, 'Ноутбук ASUS ROG Strix G16',        'SKU-LAP-001', 54999.00, 12),
    (1, 2, 'Ультрабук Apple MacBook Air 13 M3', 'SKU-LAP-002', 49999.00, 8),
    (2, 2, 'Смартфон Apple iPhone 16 Pro 256GB','SKU-PHN-001', 51999.00, 15),
    (2, 3, 'Смартфон Samsung Galaxy S24 Ultra', 'SKU-PHN-002', 47999.00, 10),
    (3, 4, 'Навушники Sony WH-1000XM5',         'SKU-AUD-001', 13499.00, 25),
    (3, 2, 'Навушники Apple AirPods Pro 2',     'SKU-AUD-002', 10499.00, 30),
    (4, 1, 'Монітор Dell UltraSharp 27 U2723QE','SKU-MON-001', 22999.00, 7),
    (5, 4, 'Механічна клавіатура Keychron K2',  'SKU-ACC-001', 4299.00,  40);

INSERT INTO product_tags (product_id, tag_name) VALUES
    (1, 'gaming'), (1, 'laptop'), (1, '16gb'), (1, 'rtx4060'),
    (2, 'apple'),  (2, 'macbook'), (2, 'm3'), (2, 'ultrabook'),
    (3, 'apple'),  (3, 'iphone'), (3, '5g'), (3, 'flagship'),
    (4, 'samsung'),(4, 'android'), (4, 's-pen'), (4, '5g'),
    (5, 'audio'),  (5, 'wireless'), (5, 'anc'), (5, 'sony'),
    (6, 'apple'),  (6, 'tws'), (6, 'anc'), (6, 'usb-c'),
    (7, 'monitor'),(7, '4k'), (7, 'ips'), (7, 'usb-c'),
    (8, 'keyboard'),(8, 'mechanical'), (8, 'wireless');

INSERT INTO shipping_cities (city_name, delivery_tariff) VALUES
    ('Київ',   100.00),
    ('Львів',  150.00),
    ('Одеса',  180.00),
    ('Дніпро', 160.00),
    ('Харків', 150.00);

INSERT INTO orders (customer_id, shipping_city_id, order_date, status, shipping_address, total_amount) VALUES
    (1, 1, '2026-09-16 12:30:00', 'completed', 'вул. Хрещатик, 22, кв. 15',      65598.00),
    (2, 2, '2026-09-18 15:45:00', 'completed', 'просп. Свободи, 14, кв. 8',      56448.00),
    (1, 1, '2026-09-22 19:10:00', 'shipped',   'вул. Хрещатик, 22, кв. 15',      27398.00),
    (3, 1, '2026-09-25 11:00:00', 'paid',      'вул. Велика Васильківська, 45',  48099.00),
    (4, 3, '2026-09-28 17:20:00', 'paid',      'вул. Дерибасівська, 10, кв. 4',  13679.00),
    (5, 4, '2026-10-01 09:50:00', 'cancelled', 'просп. Дмитра Яворницького, 50', 55159.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 54999.00),
    (1, 6, 1, 10499.00),
    (2, 3, 1, 51999.00),
    (2, 8, 1, 4299.00),
    (3, 7, 1, 22999.00),
    (3, 8, 1, 4299.00),
    (4, 4, 1, 47999.00),
    (5, 5, 1, 13499.00),
    (6, 1, 1, 54999.00);

INSERT INTO payments (order_id, payment_method, amount, payment_status, paid_at) VALUES
    (1, 'card',             65598.00, 'completed', '2026-09-16 12:32:10'),
    (2, 'apple_pay',        56448.00, 'completed', '2026-09-18 15:46:05'),
    (3, 'google_pay',       27398.00, 'completed', '2026-09-22 19:12:40'),
    (4, 'card',             48099.00, 'completed', '2026-09-25 11:03:15'),
    (5, 'cash_on_delivery', 13679.00, 'completed', '2026-10-05 16:30:00'),
    (6, 'card',             55159.00, 'refunded',  '2026-10-01 09:55:00');

