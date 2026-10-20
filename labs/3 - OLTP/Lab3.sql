-- 1. Вибірка даних

-- товари категорії Ноутбуки
SELECT product_id, sku, name
FROM product
WHERE category_id = 1;

-- постачальники без email
SELECT name, phone
FROM supplier
WHERE email IS NULL;

-- надходження з 2 вересня
SELECT document_no, occurred_at, note
FROM movement
WHERE type = 'receipt'
AND occurred_at >= '2026-09-02';

-- залишки Центрального складу
SELECT p.name AS товар,
       s.quantity AS залишок
FROM stock s
JOIN product p ON p.product_id = s.product_id
WHERE s.warehouse_id = 1
ORDER BY p.name;

-- вміст документа RCV-0001 із сумою
SELECT p.name AS товар,
       mi.quantity AS кількість,
       mi.unit_cost AS ціна,
       mi.quantity * mi.unit_cost AS сума
FROM movement m
JOIN movement_item mi ON mi.movement_id = m.movement_id
JOIN product p ON p.product_id = mi.product_id
WHERE m.document_no = 'RCV-0001';

-- залишки AirPods на всіх складах
SELECT w.name AS склад,
       s.quantity AS залишок
FROM stock s
JOIN warehouse w ON w.warehouse_id = s.warehouse_id
WHERE s.product_id = (SELECT product_id FROM product WHERE sku = 'AIRPODS-4')
ORDER BY w.warehouse_id;

-- 2. Додавання даних

-- новий товар
INSERT INTO product (category_id, sku, name, unit)
VALUES (4, 'WATCH-S10-42mm', 'Apple Watch Series 10 42mm', 'шт');

-- перевірка
SELECT product_id, sku, name
FROM product
WHERE sku = 'WATCH-S10-42mm';

-- надходження RCV-0004
BEGIN;

INSERT INTO movement (warehouse_id, supplier_id, document_no, occurred_at, type, note)
VALUES (2, 1, 'RCV-0004', '2026-10-19 10:00', 'receipt', 'Поставка Apple Watch та AirPods');

INSERT INTO movement_item (movement_id, product_id, quantity, unit_cost) VALUES
    ((SELECT movement_id FROM movement WHERE document_no = 'RCV-0004'),
     (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm'), 5, 15000.00),
    ((SELECT movement_id FROM movement WHERE document_no = 'RCV-0004'),
     (SELECT product_id FROM product WHERE sku = 'AIRPODS-4'), 10, 5800.00);

INSERT INTO stock (warehouse_id, product_id, quantity) VALUES
    (2, (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm'), 5),
    (2, (SELECT product_id FROM product WHERE sku = 'AIRPODS-4'), 10)
ON CONFLICT (warehouse_id, product_id)
DO UPDATE SET quantity = stock.quantity + EXCLUDED.quantity;

COMMIT;

-- перевірка документа
SELECT m.document_no, p.name, mi.quantity, mi.unit_cost
FROM movement m
JOIN movement_item mi ON mi.movement_id = m.movement_id
JOIN product p ON p.product_id = mi.product_id
WHERE m.document_no = 'RCV-0004';

-- перевірка залишків Лівого берега
SELECT p.name AS товар, s.quantity AS залишок
FROM stock s
JOIN product p ON p.product_id = s.product_id
WHERE s.warehouse_id = 2
ORDER BY p.product_id;

-- 3. Зміна даних

-- email Фірми 2: до
SELECT supplier_id, name, email
FROM supplier
WHERE name = 'ТОВ "Фірма2"';

-- зміна
UPDATE supplier
SET email = 'firma2@gmail.com'
WHERE name = 'ТОВ "Фірма2"';

-- після
SELECT supplier_id, name, email
FROM supplier
WHERE name = 'ТОВ "Фірма2"';

-- залишки Apple Watch: до переміщення
SELECT w.name AS склад, s.quantity AS залишок
FROM stock s
JOIN warehouse w ON w.warehouse_id = s.warehouse_id
WHERE s.product_id = (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm');

-- переміщення TRF-0002
BEGIN;

INSERT INTO movement (warehouse_id, to_warehouse_id, document_no, occurred_at, type, note)
VALUES (2, 3, 'TRF-0002', '2026-10-19 12:00', 'transfer', 'Переміщення Apple Watch на Правий берег');

INSERT INTO movement_item (movement_id, product_id, quantity)
VALUES ((SELECT movement_id FROM movement WHERE document_no = 'TRF-0002'),
        (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm'), 2);

-- склад-джерело: мінус
UPDATE stock
SET quantity = quantity - 2
WHERE warehouse_id = 2
AND product_id = (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm');

-- склад призначення: плюс
INSERT INTO stock (warehouse_id, product_id, quantity)
VALUES (3, (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm'), 2)
ON CONFLICT (warehouse_id, product_id)
DO UPDATE SET quantity = stock.quantity + EXCLUDED.quantity;

COMMIT;

-- залишки Apple Watch: після переміщення
SELECT w.name AS склад, s.quantity AS залишок
FROM stock s
JOIN warehouse w ON w.warehouse_id = s.warehouse_id
WHERE s.product_id = (SELECT product_id FROM product WHERE sku = 'WATCH-S10-42mm')
ORDER BY w.warehouse_id;

-- 4. Видалення даних

SELECT supplier_id, name
FROM supplier
WHERE name = 'ФОП Фоп1';

SELECT document_no
FROM movement
WHERE supplier_id = (SELECT supplier_id FROM supplier WHERE name = 'ФОП Фоп1');

DELETE FROM supplier
WHERE name = 'ФОП Фоп1';

-- перевірка
SELECT supplier_id, name
FROM supplier
ORDER BY supplier_id;

-- Фірма 1: чи є документи
SELECT document_no
FROM movement
WHERE supplier_id = (SELECT supplier_id FROM supplier WHERE name = 'ТОВ "Фірма1"');

-- спроба видалити Фірму 1
DELETE FROM supplier
WHERE name = 'ТОВ "Фірма1"';

-- перевірка: Фірма 1 на місці
SELECT supplier_id, name
FROM supplier
ORDER BY supplier_id;

-- 5. Безпека

-- резервна копія залишків
DROP TABLE IF EXISTS stock_backup;
SELECT * INTO stock_backup FROM stock;

-- перевірка копії
SELECT count(*) FROM stock_backup;

-- помилкове обнулення і скасування
BEGIN;

UPDATE stock
SET quantity = 0
WHERE warehouse_id = 1;

SELECT warehouse_id, product_id, quantity
FROM stock
WHERE warehouse_id = 1
ORDER BY product_id;

ROLLBACK;

-- перевірка: залишки повернулись
SELECT warehouse_id, product_id, quantity
FROM stock
WHERE warehouse_id = 1
ORDER BY product_id;

-- спроба списати більше, ніж є (транзакція, очікувана помилка CHECK)
BEGIN;

INSERT INTO movement (warehouse_id, document_no, occurred_at, type, note)
VALUES (2, 'WO-0002', '2026-10-19 13:00', 'write_off', 'Тест: списання більше, ніж є');

INSERT INTO movement_item (movement_id, product_id, quantity)
VALUES ((SELECT movement_id FROM movement WHERE document_no = 'WO-0002'),
        (SELECT product_id FROM product WHERE sku = 'IPH-16-128'), 100);

-- залишок: 18 - 100 = -82, помилка
UPDATE stock
SET quantity = quantity - 100
WHERE warehouse_id = 2
AND product_id = (SELECT product_id FROM product WHERE sku = 'IPH-16-128');

ROLLBACK;

-- перевірка: документа немає
SELECT document_no
FROM movement
WHERE document_no = 'WO-0002';

-- перевірка: залишок iPhone
SELECT quantity
FROM stock
WHERE warehouse_id = 2
AND product_id = (SELECT product_id FROM product WHERE sku = 'IPH-16-128');