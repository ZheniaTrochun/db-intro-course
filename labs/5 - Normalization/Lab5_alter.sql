DROP SCHEMA IF EXISTS norm CASCADE;
CREATE SCHEMA norm;
SET search_path TO norm;

-- 1NF: одна заповнена таблиця, один рядок = один товар документа

CREATE TABLE journal (
    document_no          VARCHAR(50),
    sku                  VARCHAR(50),
    type                 VARCHAR(20)  NOT NULL,
    occurred_at          TIMESTAMP    NOT NULL,
    note                 TEXT,
    warehouse_name       VARCHAR(100) NOT NULL,
    warehouse_address    VARCHAR(255) NOT NULL,
    to_warehouse_name    VARCHAR(100),
    to_warehouse_address VARCHAR(255),
    supplier_name        VARCHAR(150),
    supplier_phone       VARCHAR(20),
    supplier_email       VARCHAR(255),
    product_name         VARCHAR(150) NOT NULL,
    category_name        VARCHAR(100) NOT NULL,
    unit                 VARCHAR(20)  NOT NULL,
    quantity             INTEGER      NOT NULL,
    unit_cost            NUMERIC(12,2),
    PRIMARY KEY (document_no, sku)
);

INSERT INTO journal VALUES
('RCV-0001','MBA-13-M3-8-256','receipt','2026-09-01 10:00','Планова поставка','Центральний склад','м. Київ, вул. Промислова, 12',NULL,NULL,'ТОВ "Фірма1"','+380441234567','firma1@gmail.com','MacBook Air 13 M3 8/256GB','Ноутбуки','шт',10,45000),
('RCV-0001','MBP-14-M4-16-512','receipt','2026-09-01 10:00','Планова поставка','Центральний склад','м. Київ, вул. Промислова, 12',NULL,NULL,'ТОВ "Фірма1"','+380441234567','firma1@gmail.com','MacBook Pro 14 M4 16/512GB','Ноутбуки','шт',6,75000),
('RCV-0001','AIRPODS-4','receipt','2026-09-01 10:00','Планова поставка','Центральний склад','м. Київ, вул. Промислова, 12',NULL,NULL,'ТОВ "Фірма1"','+380441234567','firma1@gmail.com','AirPods 4','Аксесуари','шт',50,6000),
('RCV-0002','IPH-16-128','receipt','2026-09-02 14:30',NULL,'Склад Лівий берег','м. Київ, просп. Броварський, 45',NULL,NULL,'ТОВ "Фірма2"','+380672223344',NULL,'iPhone 16 128GB','Смартфони','шт',20,36000),
('RCV-0002','AIRPODS-4','receipt','2026-09-02 14:30',NULL,'Склад Лівий берег','м. Київ, просп. Броварський, 45',NULL,NULL,'ТОВ "Фірма2"','+380672223344',NULL,'AirPods 4','Аксесуари','шт',30,5900),
('RCV-0003','IPAD-AIR-11','receipt','2026-09-05 09:15',NULL,'Центральний склад','м. Київ, вул. Промислова, 12',NULL,NULL,'ТОВ "Фірма3"','+380503334455','firma3@gmail.com','iPad Air 11 128GB','Планшети','шт',15,27000),
('TRF-0001','MBA-13-M3-8-256','transfer','2026-09-08 11:00','Поповнення складу Правий берег','Центральний склад','м. Київ, вул. Промислова, 12','Склад Правий берег','м. Київ, вул. Борщагівська, 154',NULL,NULL,NULL,'MacBook Air 13 M3 8/256GB','Ноутбуки','шт',3,NULL),
('TRF-0001','IPAD-AIR-11','transfer','2026-09-08 11:00','Поповнення складу Правий берег','Центральний склад','м. Київ, вул. Промислова, 12','Склад Правий берег','м. Київ, вул. Борщагівська, 154',NULL,NULL,NULL,'iPad Air 11 128GB','Планшети','шт',5,NULL),
('TRF-0001','AIRPODS-4','transfer','2026-09-08 11:00','Поповнення складу Правий берег','Центральний склад','м. Київ, вул. Промислова, 12','Склад Правий берег','м. Київ, вул. Борщагівська, 154',NULL,NULL,NULL,'AirPods 4','Аксесуари','шт',20,NULL),
('WO-0001','IPH-16-128','write_off','2026-09-12 16:45','Пошкоджено під час транспортування','Склад Лівий берег','м. Київ, просп. Броварський, 45',NULL,NULL,NULL,NULL,NULL,'iPhone 16 128GB','Смартфони','шт',2,NULL),
('WO-0001','AIRPODS-4','write_off','2026-09-12 16:45','Пошкоджено під час транспортування','Склад Лівий берег','м. Київ, просп. Броварський, 45',NULL,NULL,NULL,NULL,NULL,'AirPods 4','Аксесуари','шт',1,NULL);

SELECT COUNT(*) AS rows_1nf FROM journal;

-- 2NF: прибираємо часткові залежності

-- document_no → дані документа
CREATE TABLE movement AS
SELECT DISTINCT document_no, type, occurred_at, note,
       warehouse_name, warehouse_address, to_warehouse_name, to_warehouse_address,
       supplier_name, supplier_phone, supplier_email
FROM journal;
ALTER TABLE movement ADD PRIMARY KEY (document_no);

-- sku → дані товару
CREATE TABLE product AS
SELECT DISTINCT sku, product_name, category_name, unit
FROM journal;
ALTER TABLE product ADD PRIMARY KEY (sku);

-- {document_no, sku} → кількість і ціна
CREATE TABLE movement_item AS
SELECT document_no, sku, quantity, unit_cost
FROM journal;
ALTER TABLE movement_item
    ADD PRIMARY KEY (document_no, sku),
    ADD FOREIGN KEY (document_no) REFERENCES movement,
    ADD FOREIGN KEY (sku)         REFERENCES product;

-- 3NF: прибираємо транзитивні залежності

-- warehouse_name → warehouse_address
CREATE TABLE warehouse AS
SELECT warehouse_name, warehouse_address FROM movement
UNION
SELECT to_warehouse_name, to_warehouse_address FROM movement
WHERE to_warehouse_name IS NOT NULL;
ALTER TABLE warehouse ADD PRIMARY KEY (warehouse_name);

ALTER TABLE movement
    DROP COLUMN warehouse_address,
    DROP COLUMN to_warehouse_address,
    ADD FOREIGN KEY (warehouse_name)    REFERENCES warehouse,
    ADD FOREIGN KEY (to_warehouse_name) REFERENCES warehouse;

-- supplier_name → supplier_phone, supplier_email
CREATE TABLE supplier AS
SELECT DISTINCT supplier_name, supplier_phone, supplier_email
FROM movement
WHERE supplier_name IS NOT NULL;
ALTER TABLE supplier ADD PRIMARY KEY (supplier_name);

ALTER TABLE movement
    DROP COLUMN supplier_phone,
    DROP COLUMN supplier_email,
    ADD FOREIGN KEY (supplier_name) REFERENCES supplier;

-- довідник категорій
CREATE TABLE category AS
SELECT DISTINCT category_name AS name FROM product;
ALTER TABLE category
    ADD COLUMN category_id SERIAL PRIMARY KEY,
    ADD UNIQUE (name);

ALTER TABLE product ADD COLUMN category_id INTEGER REFERENCES category;
UPDATE product p
SET category_id = c.category_id
FROM category c
WHERE c.name = p.category_name;
ALTER TABLE product
    ALTER COLUMN category_id SET NOT NULL,
    DROP COLUMN category_name;

-- Перевірка

-- скільки записів у кожній таблиці
SELECT 'movement' AS tbl, COUNT(*) FROM movement
UNION ALL SELECT 'product',       COUNT(*) FROM product
UNION ALL SELECT 'movement_item', COUNT(*) FROM movement_item
UNION ALL SELECT 'warehouse',     COUNT(*) FROM warehouse
UNION ALL SELECT 'supplier',      COUNT(*) FROM supplier
UNION ALL SELECT 'category',      COUNT(*) FROM category;

-- збираємо таблиці назад і порівнюємо з початковою: 0 рядків = нічого не втрачено
SELECT j.document_no, j.sku, j.type, j.occurred_at, j.note,
       j.warehouse_name, j.warehouse_address, j.to_warehouse_name, j.to_warehouse_address,
       j.supplier_name, j.supplier_phone, j.supplier_email,
       j.product_name, j.category_name, j.unit, j.quantity, j.unit_cost
FROM journal j
EXCEPT
SELECT m.document_no, mi.sku, m.type, m.occurred_at, m.note,
       m.warehouse_name, w.warehouse_address, m.to_warehouse_name, tw.warehouse_address,
       m.supplier_name, s.supplier_phone, s.supplier_email,
       p.product_name, c.name, p.unit, mi.quantity, mi.unit_cost
FROM movement m
JOIN movement_item mi ON mi.document_no = m.document_no
JOIN product p        ON p.sku = mi.sku
JOIN category c       ON c.category_id = p.category_id
JOIN warehouse w      ON w.warehouse_name = m.warehouse_name
LEFT JOIN warehouse tw ON tw.warehouse_name = m.to_warehouse_name
LEFT JOIN supplier s   ON s.supplier_name = m.supplier_name;

SET search_path TO public;