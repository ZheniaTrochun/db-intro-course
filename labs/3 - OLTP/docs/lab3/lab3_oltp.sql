-- Лабораторна робота 3: Маніпулювання даними SQL (OLTP)
-- Скрипт самодостатній: створює схему з лабораторної 2 і заповнює її початковими даними.
-- УВАГА: DROP видаляє таблиці та дані лабораторної 2 у поточній базі.
-- Блок 4.5 (в кінці) виконувати окремо: він має завершитися помилкою.

-- 0. CREATE: схема (лабораторна 2)

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

CREATE TYPE unit_type AS ENUM ('piece', 'kg', 'liter', 'box', 'pallet');
CREATE TYPE order_status AS ENUM ('draft', 'received', 'cancelled');
CREATE TYPE movement_kind AS ENUM ('transfer', 'write_off');

CREATE TABLE supplier (
    supplier_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name   VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    phone          VARCHAR(20)  NOT NULL CHECK (phone LIKE '+%'),
    email          VARCHAR(100) NOT NULL UNIQUE,
    address        VARCHAR(255) NOT NULL
);

CREATE TABLE product (
    product_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku_code        VARCHAR(50)  NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    unit            unit_type    NOT NULL DEFAULT 'piece',
    min_stock_level INTEGER      NOT NULL DEFAULT 0 CHECK (min_stock_level >= 0)
);

CREATE TABLE warehouse_location (
    location_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_code VARCHAR(50) NOT NULL UNIQUE,
    zone          VARCHAR(50) NOT NULL,
    shelf_number  VARCHAR(50) NOT NULL,
    max_capacity  INTEGER     NOT NULL CHECK (max_capacity > 0),
    CONSTRAINT uk_zone_shelf UNIQUE (zone, shelf_number)
);

CREATE TABLE supply_order (
    order_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_number VARCHAR(50)   NOT NULL UNIQUE,
    supplier_id  INTEGER       NOT NULL REFERENCES supplier (supplier_id),
    supply_date  TIMESTAMP     NOT NULL DEFAULT now(),
    total_cost   NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_cost >= 0),
    status       order_status  NOT NULL DEFAULT 'draft'
);

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

CREATE TABLE inventory_stock (
    product_id  INTEGER NOT NULL REFERENCES product (product_id),
    location_id INTEGER NOT NULL REFERENCES warehouse_location (location_id),
    quantity    INTEGER NOT NULL CHECK (quantity >= 0),
    PRIMARY KEY (product_id, location_id)
);

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

-- Початкові дані

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

INSERT INTO supply_order (order_number, supplier_id, total_cost, status) VALUES
('ORD-2026-01', 1, 105000.00, 'received'),
('ORD-2026-02', 3,  42000.00, 'received'),
('ORD-2026-03', 4,  18500.00, 'received'),
('ORD-2026-04', 2,  12000.00, 'draft'),
('ORD-2026-05', 5,  34000.00, 'cancelled');

INSERT INTO supply_item (order_id, product_id, location_id, quantity, unit_price, batch_number, expiry_date) VALUES
(1, 1, 1,  30, 2500.00, 'P-2026-0101', NULL),
(1, 2, 2, 100,  300.00, 'P-2026-0101', '2027-12-31'),
(2, 3, 3, 500,   60.00, 'P-2026-0202', NULL),
(2, 4, 5,  10, 1200.00, 'P-2026-0202', '2028-06-30'),
(3, 5, 5,  20,  925.00, 'P-2026-0303', NULL),
(4, 3, 3, 200,   60.00, 'P-2026-0404', NULL),
(5, 5, 5,  40,  850.00, 'P-2026-0505', NULL);

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

INSERT INTO inventory_movement (movement_type, product_id, from_location_id, to_location_id, quantity, reason, created_by) VALUES
('transfer',  1, 1, 3,    20, 'Поповнення комірки LOC-B-1', 'Петренко А.'),
('transfer',  3, 3, 4,    50, 'Перенесення на LOC-C-1',     'Петренко А.'),
('write_off', 3, 4, NULL,  5, 'Пошкодження упаковки',       'Іваненко О.'),
('transfer',  2, 2, 1,    10, 'Перенесення на LOC-A-1',     'Іваненко О.'),
('transfer',  5, 5, 2,     5, 'Перенесення на LOC-A-2',     'Петренко А.');

-- Початковий стан
SELECT * FROM supplier;
SELECT * FROM product;
SELECT * FROM warehouse_location;
SELECT * FROM supply_order;


-- 1. SELECT

-- 1.1
SELECT supplier_id, company_name, phone, email
FROM supplier;

-- 1.2
SELECT sku_code, name, min_stock_level
FROM product
WHERE unit = 'box';

-- 1.3
SELECT sku_code, name
FROM product
WHERE name ILIKE '%кабель%';

-- 1.4
SELECT order_number, total_cost, status
FROM supply_order
WHERE total_cost > 20000
ORDER BY total_cost DESC;

-- 1.5
SELECT order_number, status, supply_date
FROM supply_order
WHERE status IN ('draft', 'cancelled');

-- 1.6
SELECT order_id, product_id, batch_number
FROM supply_item
WHERE expiry_date IS NULL;

-- 1.7 Помилка: "= NULL" завжди порожній результат
SELECT order_id, product_id
FROM supply_item
WHERE expiry_date = NULL;

-- 1.8
SELECT order_id, product_id, unit_price
FROM supply_item
WHERE unit_price BETWEEN 300 AND 1000
ORDER BY unit_price;

-- 1.9
SELECT location_code, zone, max_capacity
FROM warehouse_location
ORDER BY max_capacity DESC, location_code
LIMIT 3;

-- 1.10
SELECT
    count(*)                                           AS total_orders,
    count(*) FILTER (WHERE status = 'received')        AS received_orders,
    sum(total_cost) FILTER (WHERE status = 'received') AS received_sum
FROM supply_order;

-- 1.11
SELECT sum(quantity) AS total_qty
FROM inventory_stock
WHERE product_id = (SELECT product_id FROM product WHERE sku_code = 'SKU-PATCH-1M');

-- 1.12
SELECT DISTINCT created_by
FROM inventory_movement;

-- 1.13
SELECT movement_id, product_id, from_location_id, quantity, reason
FROM inventory_movement
WHERE to_location_id IS NULL;

-- 1.14
SELECT movement_id, movement_type, quantity, reason, movement_date
FROM inventory_movement
ORDER BY movement_date, movement_id;


-- 2. INSERT

-- 2.1
INSERT INTO supplier (company_name, contact_person, phone, email, address)
VALUES ('ТОВ СвітлоМережа', 'Наталія Гриценко', '+380501239876',
        'order@svitlomerezha.ua', 'м. Одеса, вул. Портова, 7')
RETURNING supplier_id, company_name;

-- 2.2
INSERT INTO product (sku_code, name, description, unit, min_stock_level)
VALUES
    ('SKU-SFP-10G',  'Модуль SFP 10G',          'Оптичний трансівер',   'piece', 15),
    ('SKU-PDU-8',    'Блок розеток 8 гнізд',    'З вимикачем',          'piece',  4),
    ('SKU-TEST-DEL', 'Тестовий товар',          NULL,                   'piece',  0);

-- 2.3
INSERT INTO warehouse_location (location_code, zone, shelf_number, max_capacity)
VALUES ('LOC-E-1', 'Зона Д', 'Стелаж 1', 250);

-- 2.4
INSERT INTO supply_order (order_number, supplier_id)
VALUES ('ORD-2026-06',
        (SELECT supplier_id FROM supplier WHERE email = 'order@svitlomerezha.ua'))
RETURNING order_id, order_number, status;

-- 2.5
INSERT INTO supply_item (order_id, product_id, location_id, quantity, unit_price, batch_number, expiry_date)
VALUES
    ((SELECT order_id FROM supply_order WHERE order_number = 'ORD-2026-06'),
     (SELECT product_id FROM product WHERE sku_code = 'SKU-SFP-10G'),
     (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-E-1'),
     20, 1450.00, 'P-2026-0606', '2028-01-31'),
    ((SELECT order_id FROM supply_order WHERE order_number = 'ORD-2026-06'),
     (SELECT product_id FROM product WHERE sku_code = 'SKU-PDU-8'),
     (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-E-1'),
     30, 320.00, 'P-2026-0606', NULL);

-- 2.6 Суму накладної БД не перераховує автоматично (spec.md, розд. 4)
UPDATE supply_order
SET total_cost = (
    SELECT sum(quantity * unit_price)
    FROM supply_item
    WHERE order_id = (SELECT order_id FROM supply_order WHERE order_number = 'ORD-2026-06')
)
WHERE order_number = 'ORD-2026-06'
RETURNING order_number, total_cost;

-- 2.7 Існуючий постачальник: 0 рядків, помилки немає
INSERT INTO supplier (company_name, contact_person, phone, email, address)
VALUES ('ТОВ Мережні Рішення', 'Василь Шевченко', '+380445556677',
        'net@solutions.ua', 'м. Київ, вул. Стецена, 12')
ON CONFLICT (email) DO NOTHING;


-- 3. UPDATE

-- 3.1
SELECT product_id, sku_code, min_stock_level
FROM product
WHERE sku_code = 'SKU-ROUTER-AC';

-- 3.2
UPDATE product
SET min_stock_level = 6,
    description = 'Двохдіапазонний роутер AC1200'
WHERE sku_code = 'SKU-ROUTER-AC'
RETURNING product_id, sku_code, min_stock_level;

-- 3.3
UPDATE supplier
SET address = 'м. Львів, вул. Зелена, 105, офіс 2'
WHERE email = 'sales@logplus.com'
RETURNING supplier_id, company_name, address;

-- 3.4 Умова status = 'draft' потрібна: БД не контролює переходи статусів
UPDATE supply_order
SET status = 'cancelled'
WHERE order_number = 'ORD-2026-04'
  AND status = 'draft'
RETURNING order_id, order_number, status;

-- 3.5 Оприбуткування ORD-2026-06 (транзакція)
BEGIN;

UPDATE supply_order
SET status = 'received'
WHERE order_number = 'ORD-2026-06'
  AND status = 'draft'
RETURNING order_id, order_number, status;
-- Має повернутися 1 рядок. Якщо 0 - ROLLBACK замість COMMIT.

INSERT INTO inventory_stock (product_id, location_id, quantity)
SELECT product_id, location_id, quantity
FROM supply_item
WHERE order_id = (SELECT order_id FROM supply_order WHERE order_number = 'ORD-2026-06')
ON CONFLICT (product_id, location_id)
DO UPDATE SET quantity = inventory_stock.quantity + excluded.quantity;

COMMIT;

-- 3.6 Переміщення і списання (транзакція)
BEGIN;

INSERT INTO inventory_movement (movement_type, product_id, from_location_id, to_location_id, quantity, reason, created_by)
VALUES
    ('transfer',
     (SELECT product_id FROM product WHERE sku_code = 'SKU-SFP-10G'),
     (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-E-1'),
     (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-A-1'),
     5, 'Поповнення комірки LOC-A-1', 'Петренко А.'),
    ('write_off',
     (SELECT product_id FROM product WHERE sku_code = 'SKU-PDU-8'),
     (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-E-1'),
     NULL,
     2, 'Пошкоджена упаковка', 'Іваненко О.');

UPDATE inventory_stock
SET quantity = quantity - 5
WHERE product_id = (SELECT product_id FROM product WHERE sku_code = 'SKU-SFP-10G')
  AND location_id = (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-E-1');

UPDATE inventory_stock
SET quantity = quantity - 2
WHERE product_id = (SELECT product_id FROM product WHERE sku_code = 'SKU-PDU-8')
  AND location_id = (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-E-1');

INSERT INTO inventory_stock (product_id, location_id, quantity)
VALUES (
    (SELECT product_id FROM product WHERE sku_code = 'SKU-SFP-10G'),
    (SELECT location_id FROM warehouse_location WHERE location_code = 'LOC-A-1'),
    5
)
ON CONFLICT (product_id, location_id)
DO UPDATE SET quantity = inventory_stock.quantity + excluded.quantity;

COMMIT;

-- 3.7
SELECT * FROM inventory_stock ORDER BY product_id, location_id;

-- 3.8 Демо: UPDATE без WHERE змінює всі рядки; ROLLBACK повертає їх назад
BEGIN;
UPDATE warehouse_location SET max_capacity = 1;
SELECT location_code, max_capacity FROM warehouse_location;
ROLLBACK;
SELECT location_code, max_capacity FROM warehouse_location;


-- 4. DELETE

-- 4.1
SELECT product_id, sku_code FROM product WHERE sku_code = 'SKU-TEST-DEL';

DELETE FROM product
WHERE sku_code = 'SKU-TEST-DEL'
RETURNING product_id, sku_code;

-- 4.2 Спочатку дочірні рядки (supply_item), потім батьківський (supply_order)
BEGIN;

SELECT order_id, product_id FROM supply_item
WHERE order_id = (SELECT order_id FROM supply_order
                  WHERE order_number = 'ORD-2026-04' AND status = 'cancelled');

DELETE FROM supply_item
WHERE order_id = (SELECT order_id FROM supply_order
                  WHERE order_number = 'ORD-2026-04' AND status = 'cancelled')
RETURNING order_id, product_id;

DELETE FROM supply_order
WHERE order_number = 'ORD-2026-04'
  AND status = 'cancelled'
RETURNING order_id, order_number;

COMMIT;

-- 4.3 Демо: DELETE з WHERE і ROLLBACK
BEGIN;
DELETE FROM inventory_movement WHERE created_by = 'Петренко А.';
ROLLBACK;
SELECT movement_id, reason FROM inventory_movement WHERE created_by = 'Петренко А.';


-- 5. Фінальна перевірка

SELECT * FROM supplier;
SELECT * FROM product;
SELECT * FROM warehouse_location;
SELECT * FROM supply_order;
SELECT * FROM supply_item;
SELECT * FROM inventory_stock ORDER BY product_id, location_id;
SELECT * FROM inventory_movement ORDER BY movement_id;


-- 4.5 Очікувана помилка (виконувати окремо): FK блокує видалення постачальника з накладними
-- DELETE FROM supplier WHERE email = 'info@electro.ua';
