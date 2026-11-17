
-- 1. supplier: email -> всі атрибути (email UNIQUE)
SELECT email, COUNT(*) AS cnt
FROM supplier
GROUP BY email
HAVING COUNT(*) > 1;

-- 2. product: sku_code -> всі атрибути (sku_code UNIQUE)
SELECT sku_code, COUNT(*) AS cnt
FROM product
GROUP BY sku_code
HAVING COUNT(*) > 1;

-- 3. warehouse_location: (zone, shelf_number) -> location_id, location_code, max_capacity
SELECT zone, shelf_number, COUNT(*) AS cnt
FROM warehouse_location
GROUP BY zone, shelf_number
HAVING COUNT(*) > 1;

-- 4. supply_order: total_cost дорівнює сумі quantity * unit_price позицій (похідний атрибут)
SELECT o.order_number,
       o.total_cost,
       COALESCE(SUM(i.quantity * i.unit_price), 0) AS calc_cost
FROM supply_order o
LEFT JOIN supply_item i ON i.order_id = o.order_id
GROUP BY o.order_id, o.order_number, o.total_cost
HAVING o.total_cost <> COALESCE(SUM(i.quantity * i.unit_price), 0);

-- 5. supply_item: чи batch_number визначається order_id (перевірка гіпотези часткової залежності)
--    Непорожній результат = у накладній є кілька партій, тобто order_id -> batch_number НЕ виконується.
SELECT order_id, COUNT(DISTINCT batch_number) AS batches
FROM supply_item
GROUP BY order_id
HAVING COUNT(DISTINCT batch_number) > 1;

-- 6. supply_item: batch_number -> expiry_date (перевірка транзитивної залежності)
--    COUNT(DISTINCT ...) ігнорує NULL, тому NULL замінюємо умовною датою.
--    Непорожній результат = одна партія має різні терміни, тобто залежності немає.
SELECT batch_number,
       COUNT(DISTINCT COALESCE(expiry_date, '1900-01-01')) AS expiry_variants
FROM supply_item
GROUP BY batch_number
HAVING COUNT(DISTINCT COALESCE(expiry_date, '1900-01-01')) > 1;

-- 7. supply_item: (order_id, product_id) -> PK (складений ключ забезпечує унікальність)
SELECT order_id, product_id, COUNT(*) AS cnt
FROM supply_item
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- 8. inventory_stock: (product_id, location_id) -> quantity (складений PK)
SELECT product_id, location_id, COUNT(*) AS cnt
FROM inventory_stock
GROUP BY product_id, location_id
HAVING COUNT(*) > 1;

-- 9. inventory_movement: переміщення мають отримувача, списання - ні (CHECK, перевірка даних)
SELECT movement_id, movement_type, to_location_id
FROM inventory_movement
WHERE (movement_type = 'transfer'  AND to_location_id IS NULL)
   OR (movement_type = 'write_off' AND to_location_id IS NOT NULL);
