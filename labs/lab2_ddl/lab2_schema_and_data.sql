-- ============================================================================
-- Лабораторна робота №2: Перетворення ER-діаграми на схему PostgreSQL
-- Предметна область: Інтернет-магазин електроніки «TechStore»
-- Виконала: Лінчевська Анастасія, група ІМ-о51
-- ============================================================================

-- ============================================================================
-- ЧАСТИНА 1: СТВОРЕННЯ ТАБЛИЦЬ (CREATE TABLE)
-- ============================================================================

-- 1. Таблиця клієнтів (customers)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name   VARCHAR(120) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(30)  NOT NULL UNIQUE,
    city        VARCHAR(80)  NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблиця категорій товарів (categories)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 3. Таблиця товарів (products)
CREATE TABLE products (
    product_id     SERIAL PRIMARY KEY,
    category_id    INTEGER       NOT NULL REFERENCES categories(category_id),
    name           VARCHAR(150)  NOT NULL,
    legacy_sku     VARCHAR(50)   UNIQUE,
    price          NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INTEGER       NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    tags           VARCHAR(255),
    supplier_name  VARCHAR(120)  NOT NULL,
    supplier_phone VARCHAR(30)   NOT NULL,
    supplier_email VARCHAR(150)  NOT NULL
);

-- 4. Таблиця замовлень (orders)
CREATE TABLE orders (
    order_id             SERIAL PRIMARY KEY,
    customer_id          INTEGER       NOT NULL REFERENCES customers(customer_id),
    order_date           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status               VARCHAR(30)   NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending', 'paid', 'shipped', 'completed', 'cancelled')),
    shipping_address     VARCHAR(255)  NOT NULL,
    shipping_city        VARCHAR(80)   NOT NULL,
    city_delivery_tariff NUMERIC(8,2)  NOT NULL DEFAULT 0.00 CHECK (city_delivery_tariff >= 0),
    total_amount         NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

-- 5. Таблиця позицій замовлення (order_items — асоціативна таблиця M:N)
CREATE TABLE order_items (
    order_id     INTEGER       NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id   INTEGER       NOT NULL REFERENCES products(product_id),
    product_name VARCHAR(150)  NOT NULL,
    quantity     INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)
);

-- 6. Таблиця платежів (payments — зв'язок 1:1 із замовленням)
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
-- ЧАСТИНА 2: НАПОВНЕННЯ ТЕСТОВИМИ ДАНИМИ (INSERT INTO)
-- ============================================================================

-- 1. Заповнення таблиці customers (6 клієнтів)
INSERT INTO customers (full_name, email, phone, city, created_at) VALUES
    ('Олександр Коваленко', 'o.kovalenko@gmail.com',  '+380501112233', 'Київ',   '2026-09-01 10:15:00'),
    ('Марія Шевченко',      'm.shevchenko@ukr.net',   '+380672223344', 'Львів',  '2026-09-03 14:20:00'),
    ('Дмитро Бондаренко',   'd.bondarenko@gmail.com', '+380633334455', 'Київ',   '2026-09-05 18:45:00'),
    ('Ірина Мельник',       'i.melnyk@outlook.com',   '+380974445566', 'Одеса',  '2026-09-10 09:30:00'),
    ('Андрій Ткаченко',     'a.tkachenko@gmail.com',  '+380935556677', 'Дніпро', '2026-09-12 16:10:00'),
    ('Наталія Кравченко',   'n.kravchenko@ukr.net',   '+380506667788', 'Львів',  '2026-09-15 11:05:00');

-- 2. Заповнення таблиці categories (5 категорій)
INSERT INTO categories (name, description) VALUES
    ('Ноутбуки',               'Портативні комп''ютери для роботи, навчання та геймінгу'),
    ('Смартфони',              'Мобільні телефони та флагманські смартфони'),
    ('Аудіотехніка',           'Бездротові навушники, гарнітури та портативна акустика'),
    ('Монітори',               'Професійні, офісні та ігрові монітори високої чіткості'),
    ('Аксесуари та периферія', 'Клавіатури, миші, зарядні пристрої та кабелі');

-- 3. Заповнення таблиці products (8 товарів)
INSERT INTO products (
    category_id, name, legacy_sku, price, stock_quantity,
    tags, supplier_name, supplier_phone, supplier_email
) VALUES
    (1, 'Ноутбук ASUS ROG Strix G16',        'SKU-LAP-001', 54999.00, 12, 'gaming, laptop, 16gb, rtx4060',  'ТОВ ТехноІмпорт',     '+380442001010', 'supply@technoimport.ua'),
    (1, 'Ультрабук Apple MacBook Air 13 M3', 'SKU-LAP-002', 49999.00, 8,  'apple, macbook, m3, ultrabook',  'ТОВ ЕплДистрибуція',  '+380443002020', 'b2b@appledist.ua'),
    (2, 'Смартфон Apple iPhone 16 Pro 256GB','SKU-PHN-001', 51999.00, 15, 'apple, iphone, 5g, flagship',    'ТОВ ЕплДистрибуція',  '+380443002020', 'b2b@appledist.ua'),
    (2, 'Смартфон Samsung Galaxy S24 Ultra', 'SKU-PHN-002', 47999.00, 10, 'samsung, android, s-pen, 5g',    'ТОВ СамітЕлектронікс','+380444003030', 'orders@summit-elec.ua'),
    (3, 'Навушники Sony WH-1000XM5',         'SKU-AUD-001', 13499.00, 25, 'audio, wireless, anc, sony',     'ТОВ СаундПро',        '+380445004040', 'sales@soundpro.ua'),
    (3, 'Навушники Apple AirPods Pro 2',     'SKU-AUD-002', 10499.00, 30, 'apple, tws, anc, usb-c',         'ТОВ ЕплДистрибуція',  '+380443002020', 'b2b@appledist.ua'),
    (4, 'Монітор Dell UltraSharp 27 U2723QE','SKU-MON-001', 22999.00, 7,  'monitor, 4k, ips, usb-c',        'ТОВ ТехноІмпорт',     '+380442001010', 'supply@technoimport.ua'),
    (5, 'Механічна клавіатура Keychron K2',  'SKU-ACC-001', 4299.00,  40, 'keyboard, mechanical, wireless', 'ТОВ СаундПро',        '+380445004040', 'sales@soundpro.ua');

-- 4. Заповнення таблиці orders (6 замовлень)
INSERT INTO orders (
    customer_id, order_date, status,
    shipping_address, shipping_city, city_delivery_tariff, total_amount
) VALUES
    (1, '2026-09-16 12:30:00', 'completed', 'вул. Хрещатик, 22, кв. 15',      'Київ',   100.00, 65598.00),
    (2, '2026-09-18 15:45:00', 'completed', 'просп. Свободи, 14, кв. 8',      'Львів',  150.00, 56448.00),
    (1, '2026-09-22 19:10:00', 'shipped',   'вул. Хрещатик, 22, кв. 15',      'Київ',   100.00, 27398.00),
    (3, '2026-09-25 11:00:00', 'paid',      'вул. Велика Васильківська, 45',  'Київ',   100.00, 48099.00),
    (4, '2026-09-28 17:20:00', 'pending',   'вул. Дерибасівська, 10, кв. 4',  'Одеса',  180.00, 13679.00),
    (5, '2026-10-01 09:50:00', 'cancelled', 'просп. Дмитра Яворницького, 50', 'Дніпро', 160.00, 55159.00);

-- 5. Заповнення таблиці order_items (9 позицій замовлень)
INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price) VALUES
    (1, 1, 'Ноутбук ASUS ROG Strix G16',         1, 54999.00),
    (1, 6, 'Навушники Apple AirPods Pro 2',      1, 10499.00),
    (2, 3, 'Смартфон Apple iPhone 16 Pro 256GB', 1, 51999.00),
    (2, 8, 'Механічна клавіатура Keychron K2',   1, 4299.00),
    (3, 7, 'Монітор Dell UltraSharp 27 U2723QE', 1, 22999.00),
    (3, 8, 'Механічна клавіатура Keychron K2',   1, 4299.00),
    (4, 4, 'Смартфон Samsung Galaxy S24 Ultra',  1, 47999.00),
    (5, 5, 'Навушники Sony WH-1000XM5',          1, 13499.00),
    (6, 1, 'Ноутбук ASUS ROG Strix G16',         1, 54999.00);

-- 6. Заповнення таблиці payments (6 платежів)
INSERT INTO payments (order_id, payment_method, amount, payment_status, paid_at) VALUES
    (1, 'card',             65598.00, 'completed', '2026-09-16 12:32:10'),
    (2, 'apple_pay',        56448.00, 'completed', '2026-09-18 15:46:05'),
    (3, 'google_pay',       27398.00, 'completed', '2026-09-22 19:12:40'),
    (4, 'card',             48099.00, 'completed', '2026-09-25 11:03:15'),
    (5, 'cash_on_delivery', 13679.00, 'pending',   NULL),
    (6, 'card',             55159.00, 'refunded',  '2026-10-01 09:55:00');
