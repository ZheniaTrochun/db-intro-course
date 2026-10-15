-- =====================================================================
-- Logistics WMS: схема PostgreSQL (лабораторна робота 2)
-- Виконувати в базі logistics. Скрипт видаляє і створює об'єкти заново.
-- Використано лише конструкції з лекцій 1-3: CREATE TABLE, enum,
-- GENERATED ALWAYS AS IDENTITY, PRIMARY KEY, FOREIGN KEY, NOT NULL,
-- UNIQUE, CHECK, DEFAULT.
-- Тести обмежень: docs/adr/tests.sql
-- =====================================================================

DROP TABLE IF EXISTS inventory_movement;
DROP TABLE IF EXISTS inventory_stock;
DROP TABLE IF EXISTS supply_item;
DROP TABLE IF EXISTS supply_order;
DROP TABLE IF EXISTS warehouse_location;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS supplier;
DROP TYPE IF EXISTS movement_kind;
DROP TYPE IF EXISTS order_status;
DROP TYPE IF EXISTS unit_type;

-- =====================================================================
-- Типи enum
-- =====================================================================
CREATE TYPE unit_type AS ENUM ('piece', 'kg', 'liter', 'box', 'pallet');
CREATE TYPE order_status AS ENUM ('draft', 'received', 'cancelled');
CREATE TYPE movement_kind AS ENUM ('transfer', 'write_off');

-- =====================================================================
-- Таблиці
-- =====================================================================

-- Постачальник
CREATE TABLE supplier (
    supplier_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name   VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    phone          VARCHAR(20)  NOT NULL CHECK (phone LIKE '+%'),
    email          VARCHAR(100) NOT NULL UNIQUE,
    address        VARCHAR(255) NOT NULL
);

-- Товар
CREATE TABLE product (
    product_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku_code        VARCHAR(50)  NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    unit            unit_type    NOT NULL DEFAULT 'piece',
    min_stock_level INTEGER      NOT NULL DEFAULT 0 CHECK (min_stock_level >= 0)
);

-- Комірка складу
CREATE TABLE warehouse_location (
    location_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_code VARCHAR(50) NOT NULL UNIQUE,
    zone          VARCHAR(50) NOT NULL,
    shelf_number  VARCHAR(50) NOT NULL,
    max_capacity  INTEGER     NOT NULL CHECK (max_capacity > 0),
    CONSTRAINT uk_zone_shelf UNIQUE (zone, shelf_number)
);

-- Накладна постачання
CREATE TABLE supply_order (
    order_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_number VARCHAR(50)   NOT NULL UNIQUE,
    supplier_id  INTEGER       NOT NULL REFERENCES supplier (supplier_id),
    supply_date  TIMESTAMP     NOT NULL DEFAULT now(),
    total_cost   NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_cost >= 0),
    status       order_status  NOT NULL DEFAULT 'draft'
);

-- Позиція накладної (таблиця сполучення товар-накладна, M:N)
CREATE TABLE supply_item (
    order_id     INTEGER       NOT NULL REFERENCES supply_order (order_id),
    product_id   INTEGER       NOT NULL REFERENCES product (product_id),
    location_id  INTEGER       NOT NULL REFERENCES warehouse_location (location_id),
    quantity     INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    batch_number VARCHAR(50)   NOT NULL,
    expiry_date  DATE,
    PRIMARY KEY (order_id, product_id)
);

-- Залишок товару в комірці (таблиця сполучення товар-комірка, M:N)
CREATE TABLE inventory_stock (
    product_id  INTEGER NOT NULL REFERENCES product (product_id),
    location_id INTEGER NOT NULL REFERENCES warehouse_location (location_id),
    quantity    INTEGER NOT NULL CHECK (quantity >= 0),
    PRIMARY KEY (product_id, location_id)
);

-- Переміщення та списання
CREATE TABLE inventory_movement (
    movement_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    movement_type    movement_kind NOT NULL,
    product_id       INTEGER       NOT NULL REFERENCES product (product_id),
    from_location_id INTEGER       NOT NULL REFERENCES warehouse_location (location_id),
    to_location_id   INTEGER       REFERENCES warehouse_location (location_id),
    quantity         INTEGER       NOT NULL CHECK (quantity > 0),
    reason           VARCHAR(255),
    movement_date    TIMESTAMP     NOT NULL DEFAULT now(),
    created_by       VARCHAR(100)  NOT NULL,
    CONSTRAINT chk_different_locations CHECK (from_location_id <> to_location_id),
    CONSTRAINT chk_movement_target CHECK (
        (movement_type = 'transfer'  AND to_location_id IS NOT NULL)
        OR (movement_type = 'write_off' AND to_location_id IS NULL)
    )
);

-- =====================================================================
-- Тестові дані
-- Батьківські таблиці заповнюються першими. Ідентифікатори GENERATED ALWAYS
-- не задаються вручну; після перестворення таблиць вони починаються з 1.
-- Залишки і суми накладних порахувати вручну (без тригерів).
-- =====================================================================

INSERT INTO supplier (company_name, contact_person, phone, email, address) VALUES
('ТОВ ЕлектроПостач',     'Олексій Коваленко', '+380441112233', 'info@electro.ua',     'м. Київ, вул. Польова, 21'),
('ПП Логістік Плюс',      'Марія Бондаренко',  '+380502223344', 'sales@logplus.com',   'м. Львів, вул. Зелена, 105'),
('ТОВ КабельТрейд',        'Дмитро Мельник',    '+380673334455', 'contact@cabletrade.ua','м. Дніпро, вул. Будівельна, 4'),
('ПрАТ ТехноСвіт',         'Ірина Ткаченко',    '+380634445566', 'support@technosvit.ua','м. Харків, просп. Науки, 40'),
('ТОВ Мережні Рішення',   'Василь Шевченко',   '+380445556677', 'net@solutions.ua',    'м. Київ, вул. Стецена, 12');

INSERT INTO product (sku_code, name, description, unit, min_stock_level) VALUES
('SKU-UTP-5E',    'Кабель вита пара UTP Cat5e',   'Бухта 305м',           'box',   10),
('SKU-RJ45-100',  'Конектори RJ-45',              'Упаковка 100 шт',      'box',   25),
('SKU-PATCH-1M',  'Патчкорд UTP 1м',              'Мережевий кабель',     'piece', 50),
('SKU-ROUTER-AC', 'Маршрутизатор Wi-Fi AC1200',   'Двохдіапазонний роутер','piece', 5),
('SKU-SWITCH-8P', 'Комутатор 8 портів Gigabit',   'Некерований комутатор','piece', 8);

INSERT INTO warehouse_location (location_code, zone, shelf_number, max_capacity) VALUES
('LOC-A-1', 'Зона А', 'Стелаж 1', 500),
('LOC-A-2', 'Зона А', 'Стелаж 2', 500),
('LOC-B-1', 'Зона Б', 'Стелаж 1', 2000),
('LOC-C-1', 'Зона В', 'Стелаж 1', 300),
('LOC-D-1', 'Зона Г', 'Стелаж 1', 100);

-- Накладні: 1-3 отримані, 4 чернетка, 5 скасована
-- total_cost = сума quantity * unit_price позицій
INSERT INTO supply_order (order_number, supplier_id, total_cost, status) VALUES
('ORD-2026-01', 1, 105000.00, 'received'),
('ORD-2026-02', 3,  42000.00, 'received'),
('ORD-2026-03', 4,  18500.00, 'received'),
('ORD-2026-04', 2,  12000.00, 'draft'),
('ORD-2026-05', 5,  34000.00, 'cancelled');

-- Позиції: order_id, product_id, location_id (комірка приймання), кількість, ціна, партія, термін
INSERT INTO supply_item (order_id, product_id, location_id, quantity, unit_price, batch_number, expiry_date) VALUES
(1, 1, 1,  30, 2500.00, 'P-2026-0101', NULL),
(1, 2, 2, 100,  300.00, 'P-2026-0101', '2027-12-31'),
(2, 3, 3, 500,   60.00, 'P-2026-0202', NULL),
(2, 4, 5,  10, 1200.00, 'P-2026-0202', '2028-06-30'),
(3, 5, 5,  20,  925.00, 'P-2026-0303', NULL),
(4, 3, 3, 200,   60.00, 'P-2026-0404', NULL),
(5, 5, 5,  40,  850.00, 'P-2026-0505', NULL);

-- Залишки після оприбуткування накладних 1-3 і переміщень/списань нижче
INSERT INTO inventory_stock (product_id, location_id, quantity) VALUES
(1, 1,  10),
(1, 3,  20),
(2, 1,  10),
(2, 2,  90),
(3, 3, 450),
(3, 4,  45),
(4, 5,  10),
(5, 2,   5),
(5, 5,  15);

-- Переміщення і списання (журнал)
INSERT INTO inventory_movement (movement_type, product_id, from_location_id, to_location_id, quantity, reason, created_by) VALUES
('transfer',  1, 1, 3,    20, 'Поповнення комірки LOC-B-1', 'Петренко А.'),
('transfer',  3, 3, 4,    50, 'Перенесення на LOC-C-1',     'Петренко А.'),
('write_off', 3, 4, NULL,  5, 'Пошкодження упаковки',       'Іваненко О.'),
('transfer',  2, 2, 1,    10, 'Перенесення на LOC-A-1',     'Іваненко О.'),
('transfer',  5, 5, 2,     5, 'Перенесення на LOC-A-2',     'Петренко А.');

-- =====================================================================
-- Перевірка результату
-- =====================================================================
SELECT * FROM supplier;
SELECT * FROM product;
SELECT * FROM warehouse_location;
SELECT * FROM supply_order;
SELECT * FROM supply_item;
SELECT * FROM inventory_stock;
SELECT * FROM inventory_movement;
