-- =====================================================================
-- Тести обмежень для схеми logistics (після schema.sql).
-- Кожен запит має завершитися ПОМИЛКОЮ - це очікувана поведінка БД.
-- Запускати по одному блоку (кожен блок окремо, у pgAdmin).
-- =====================================================================

-- 1. UNIQUE: дубль артикула товару
INSERT INTO product (sku_code, name) VALUES ('SKU-UTP-5E', 'Дубль');

-- 2. CHECK: телефон постачальника без знака +
INSERT INTO supplier (company_name, contact_person, phone, email, address)
VALUES ('X', 'Y', '380500000001', 'new@x.ua', 'адреса');

-- 3. FOREIGN KEY: накладна на неіснуючого постачальника
INSERT INTO supply_order (order_number, supplier_id) VALUES ('ORD-X', 999);

-- 4. ENUM: недопустима одиниця виміру
INSERT INTO product (sku_code, name, unit) VALUES ('SKU-X-1', 'X', 'bottle');

-- 5. CHECK: від'ємний залишок
UPDATE inventory_stock SET quantity = -1 WHERE product_id = 1 AND location_id = 1;

-- 6. CHECK: переміщення в ту саму комірку
INSERT INTO inventory_movement (movement_type, product_id, from_location_id, to_location_id, quantity, created_by)
VALUES ('transfer', 1, 1, 1, 1, 'test');

-- 7. CHECK: списання з коміркою-отримувачем
INSERT INTO inventory_movement (movement_type, product_id, from_location_id, to_location_id, quantity, created_by)
VALUES ('write_off', 3, 4, 2, 1, 'test');

-- 8. CHECK: нульова кількість у позиції накладної
INSERT INTO supply_item (order_id, product_id, location_id, quantity, unit_price, batch_number)
VALUES (4, 2, 1, 0, 1.00, 'T');

-- 9. NOT NULL: переміщення без автора
INSERT INTO inventory_movement (movement_type, product_id, from_location_id, to_location_id, quantity)
VALUES ('transfer', 1, 1, 2, 1);
