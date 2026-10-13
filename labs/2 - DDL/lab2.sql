DROP TABLE IF EXISTS stock, movement_item, movement, product, supplier, warehouse, category;
DROP TYPE IF EXISTS movement_type;

CREATE TYPE movement_type AS ENUM ('receipt', 'write_off', 'transfer');

CREATE TABLE category (
                          category_id SERIAL       PRIMARY KEY,
                          name        VARCHAR(100) NOT NULL UNIQUE CHECK (btrim(name) <> '')
);

CREATE TABLE warehouse (
                           warehouse_id SERIAL       PRIMARY KEY,
                           name         VARCHAR(100) NOT NULL CHECK (btrim(name) <> ''),
                           address      VARCHAR(255) NOT NULL CHECK (btrim(address) <> '')
);

CREATE TABLE supplier (
                          supplier_id SERIAL       PRIMARY KEY,
                          name        VARCHAR(150) NOT NULL CHECK (btrim(name) <> ''),
                          phone       VARCHAR(20),
                          email       VARCHAR(255) CHECK (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$')
    );

CREATE TABLE product (
                         product_id  SERIAL       PRIMARY KEY,
                         category_id INTEGER      NOT NULL REFERENCES category(category_id) ON DELETE RESTRICT,
                         sku         VARCHAR(50)  NOT NULL UNIQUE CHECK (btrim(sku) <> ''),
                         name        VARCHAR(150) NOT NULL CHECK (btrim(name) <> ''),
                         unit        VARCHAR(20)  NOT NULL CHECK (btrim(unit) <> '')
);

CREATE TABLE movement (
                          movement_id     SERIAL        PRIMARY KEY,
                          warehouse_id    INTEGER       NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
                          to_warehouse_id INTEGER       REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
                          supplier_id     INTEGER       REFERENCES supplier(supplier_id) ON DELETE RESTRICT,
                          document_no     VARCHAR(50)   NOT NULL UNIQUE CHECK (btrim(document_no) <> ''),
                          occurred_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          type            movement_type NOT NULL,
                          note            TEXT,

                          CONSTRAINT chk_movement_receipt CHECK (
                              type <> 'receipt'
                                  OR (supplier_id IS NOT NULL AND to_warehouse_id IS NULL)
                              ),

                          CONSTRAINT chk_movement_write_off CHECK (
                              type <> 'write_off'
                                  OR (supplier_id IS NULL AND to_warehouse_id IS NULL
                                  AND note IS NOT NULL AND btrim(note) <> '')
                              ),

                          CONSTRAINT chk_movement_transfer CHECK (
                              type <> 'transfer'
                                  OR (to_warehouse_id IS NOT NULL
                                  AND to_warehouse_id <> warehouse_id
                                  AND supplier_id IS NULL)
                              )
);

CREATE TABLE movement_item (
                               movement_id INTEGER       REFERENCES movement(movement_id) ON DELETE RESTRICT,
                               product_id  INTEGER       REFERENCES product(product_id) ON DELETE RESTRICT,
                               quantity    INTEGER       NOT NULL CHECK (quantity > 0),
                               unit_cost   NUMERIC(12,2) CHECK (unit_cost >= 0),
                               PRIMARY KEY (movement_id, product_id)
);

CREATE TABLE stock (
                       warehouse_id INTEGER       REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT,
                       product_id   INTEGER       REFERENCES product(product_id) ON DELETE RESTRICT,
                       quantity     INTEGER       NOT NULL DEFAULT 0 CHECK (quantity >= 0),
                       PRIMARY KEY (warehouse_id, product_id)
);

-- Тестові дані

INSERT INTO category (name) VALUES
                                ('Ноутбуки'),
                                ('Смартфони'),
                                ('Планшети'),
                                ('Аксесуари');

INSERT INTO warehouse (name, address) VALUES
                                          ('Центральний склад',  'м. Київ, вул. Промислова, 12'),
                                          ('Склад Лівий берег',  'м. Київ, просп. Броварський, 45'),
                                          ('Склад Правий берег', 'м. Київ, вул. Борщагівська, 154');

INSERT INTO supplier (name, phone, email) VALUES
                                              ('ТОВ "Фірма1"', '+380441234567', 'firma1@gmail.com'),
                                              ('ТОВ "Фірма2"', '+380672223344', NULL),
                                              ('ТОВ "Фірма3"', '+380503334455', 'firma3@gmail.com'),
                                              ('ФОП Фоп1',     NULL,            'fop1@gmail.com');

INSERT INTO product (category_id, sku, name, unit) VALUES
                                                       (1, 'MBA-13-M3-8-256',  'MacBook Air 13 M3 8/256GB',  'шт'),
                                                       (1, 'MBP-14-M4-16-512', 'MacBook Pro 14 M4 16/512GB', 'шт'),
                                                       (2, 'IPH-16-128',       'iPhone 16 128GB',            'шт'),
                                                       (3, 'IPAD-AIR-11',      'iPad Air 11 128GB',          'шт'),
                                                       (4, 'AIRPODS-4',        'AirPods 4',                  'шт');

INSERT INTO movement (warehouse_id, to_warehouse_id, supplier_id, document_no, occurred_at, type, note) VALUES
                                                                                                            (1, NULL, 1,    'RCV-0001', '2026-09-01 10:00', 'receipt',   'Планова поставка'),
                                                                                                            (2, NULL, 2,    'RCV-0002', '2026-09-02 14:30', 'receipt',   NULL),
                                                                                                            (1, NULL, 3,    'RCV-0003', '2026-09-05 09:15', 'receipt',   NULL),
                                                                                                            (1, 3,    NULL, 'TRF-0001', '2026-09-08 11:00', 'transfer',  'Поповнення складу Правий берег зі складу Центральний'),
                                                                                                            (2, NULL, NULL, 'WO-0001',  '2026-09-12 16:45', 'write_off', 'Пошкоджено під час транспортування');

INSERT INTO movement_item (movement_id, product_id, quantity, unit_cost) VALUES
                                                                             (1, 1, 10, 45000.00),
                                                                             (1, 2, 6,  75000.00),
                                                                             (1, 5, 50, 6000.00),
                                                                             (2, 3, 20, 36000.00),
                                                                             (2, 5, 30, 5900.00),
                                                                             (3, 4, 15, 27000.00),
                                                                             (4, 1, 3,  NULL),
                                                                             (4, 4, 5,  NULL),
                                                                             (4, 5, 20, NULL),
                                                                             (5, 3, 2,  NULL),
                                                                             (5, 5, 1,  NULL);

INSERT INTO stock (warehouse_id, product_id, quantity) VALUES
                                                           (1, 1, 7),
                                                           (1, 2, 6),
                                                           (1, 4, 10),
                                                           (1, 5, 30),
                                                           (2, 3, 18),
                                                           (2, 5, 29),
                                                           (3, 1, 3),
                                                           (3, 4, 5),
                                                           (3, 5, 20);

-- перевірка

SELECT * FROM category;
SELECT * FROM warehouse;
SELECT * FROM supplier;
SELECT * FROM product;
SELECT * FROM movement;
SELECT * FROM movement_item;
SELECT * FROM stock;