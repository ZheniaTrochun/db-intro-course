
-- 0. Перевірка наявності даних (кількість записів у таблицях)
SELECT COUNT(*) AS suppliers FROM supplier;
SELECT COUNT(*) AS products FROM product;
SELECT COUNT(*) AS locations FROM warehouse_location;
SELECT COUNT(*) AS orders FROM supply_order;
SELECT COUNT(*) AS order_items FROM supply_item;
SELECT COUNT(*) AS stock_rows FROM inventory_stock;
SELECT COUNT(*) AS movements FROM inventory_movement;

-- 1. Базова агрегація (одна таблиця)

-- 1.1 Кількість товарів у довіднику
SELECT COUNT(*) AS total_products
FROM product;

-- 1.2 Загальна кількість одиниць товару на складі (усі комірки)
SELECT COALESCE(SUM(quantity), 0) AS total_stock_qty
FROM inventory_stock;

-- 1.3 Середній мінімальний залишок товарів
SELECT ROUND(AVG(min_stock_level), 2) AS avg_min_stock_level
FROM product;

-- 1.4 Мінімальна і максимальна місткість комірки
SELECT MIN(max_capacity) AS min_capacity,
       MAX(max_capacity) AS max_capacity,
       ROUND(AVG(max_capacity), 2) AS avg_capacity
FROM warehouse_location;

-- 1.5 Зведення по накладних: усього, отриманих, сума отриманих (FILTER)
SELECT COUNT(*)                                           AS total_orders,
       COUNT(*) FILTER (WHERE status = 'received')        AS received_orders,
       COUNT(*) FILTER (WHERE status = 'cancelled')       AS cancelled_orders,
       SUM(total_cost) FILTER (WHERE status = 'received') AS received_sum
FROM supply_order;

-- 2. Групування (GROUP BY)

-- 2.1 Загальний залишок по кожному товару (усі комірки), включно з товарами без залишків
SELECT p.sku_code,
       p.name,
       COALESCE(SUM(s.quantity), 0) AS total_qty
FROM product p
LEFT JOIN inventory_stock s ON s.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_qty DESC, p.sku_code;

-- 2.2 Кількість комірок і сумарна місткість за зонами
SELECT zone,
       COUNT(*) AS locations,
       SUM(max_capacity) AS total_capacity
FROM warehouse_location
GROUP BY zone
ORDER BY zone;

-- 2.3 Кількість і сума накладних за статусом
SELECT status,
       COUNT(*) AS orders_count,
       COALESCE(SUM(total_cost), 0) AS total_value
FROM supply_order
GROUP BY status
ORDER BY status;

-- 2.4 Кількість операцій і обсяг за типом руху та автором
SELECT movement_type,
       created_by,
       COUNT(*) AS ops_count,
       COALESCE(SUM(quantity), 0) AS total_qty
FROM inventory_movement
GROUP BY movement_type, created_by
ORDER BY movement_type, created_by;

-- 2.5 Середня ціна постачання і обсяг за товаром (усі товари; враховуються лише позиції отриманих накладних)
SELECT p.sku_code,
       ROUND(AVG(si.unit_price), 2) AS avg_unit_price,
       COALESCE(SUM(si.quantity), 0) AS total_qty
FROM product p
LEFT JOIN (supply_item si
           JOIN supply_order o ON o.order_id = si.order_id
                             AND o.status = 'received')
  ON si.product_id = p.product_id
GROUP BY p.product_id
ORDER BY avg_unit_price DESC NULLS LAST;

-- 3. Фільтрація груп (HAVING)

-- 3.1 Комірки, у яких сумарний залишок перевищує 100 одиниць
SELECT w.location_code,
       w.zone,
       SUM(s.quantity) AS total_qty,
       w.max_capacity
FROM warehouse_location w
JOIN inventory_stock s ON s.location_id = w.location_id
GROUP BY w.location_id
HAVING SUM(s.quantity) > 100
ORDER BY total_qty DESC;

-- 3.2 Постачальники, у яких сума отриманих накладних перевищує 30000
SELECT s.company_name,
       COUNT(o.order_id) AS received_orders,
       SUM(o.total_cost) AS total_value
FROM supplier s
JOIN supply_order o ON o.supplier_id = s.supplier_id
WHERE o.status = 'received'
GROUP BY s.supplier_id
HAVING SUM(o.total_cost) > 30000
ORDER BY total_value DESC;

-- 3.3 Товари, що зберігаються більше ніж в одній комірці
SELECT p.sku_code,
       COUNT(s.location_id) AS locations_with_stock
FROM product p
JOIN inventory_stock s ON s.product_id = p.product_id
GROUP BY p.product_id
HAVING COUNT(s.location_id) > 1
ORDER BY locations_with_stock DESC, p.sku_code;

-- 4. JOIN (різні типи)

-- 4.1 INNER JOIN: накладні разом із постачальниками
SELECT o.order_number,
       s.company_name,
       o.status,
       o.total_cost
FROM supply_order o
INNER JOIN supplier s ON s.supplier_id = o.supplier_id
ORDER BY o.order_number;

-- 4.2 LEFT JOIN: усі постачальники, навіть без накладних
SELECT s.company_name,
       COUNT(o.order_id) AS orders_count,
       COALESCE(SUM(o.total_cost), 0) AS total_value
FROM supplier s
LEFT JOIN supply_order o ON o.supplier_id = s.supplier_id
GROUP BY s.supplier_id
ORDER BY s.company_name;

-- 4.3 RIGHT JOIN: усі комірки, навіть ті, куди не було приймання по накладних
SELECT w.location_code,
       si.order_id,
       si.product_id,
       si.quantity
FROM supply_item si
RIGHT JOIN warehouse_location w ON w.location_id = si.location_id
ORDER BY w.location_code, si.order_id, si.product_id;

-- 4.4 FULL OUTER JOIN: товари із залишками та товари з рухами (щоб знайти товари без рухів)
SELECT product_id,
       p.sku_code,
       COALESCE(st.stock_qty, 0) AS stock_qty,
       COALESCE(mv.moved_qty, 0) AS moved_qty
FROM (SELECT product_id, SUM(quantity) AS stock_qty
      FROM inventory_stock
      GROUP BY product_id) AS st
FULL OUTER JOIN (SELECT product_id, SUM(quantity) AS moved_qty
                 FROM inventory_movement
                 GROUP BY product_id) AS mv
  USING (product_id)
LEFT JOIN product p USING (product_id)
ORDER BY product_id;

-- 4.5 CROSS JOIN + NOT EXISTS: пари (товар, комірка), для яких ще немає залишку
SELECT p.sku_code,
       w.location_code
FROM product p
CROSS JOIN warehouse_location w
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory_stock s
    WHERE s.product_id = p.product_id
      AND s.location_id = w.location_id
)
ORDER BY p.sku_code, w.location_code;

-- 5. Підзапити

-- 5.1 Скалярний підзапит у SELECT: частка кожного товару в загальному залишку
SELECT p.sku_code,
       COALESCE(SUM(s.quantity), 0) AS stock_qty,
       ROUND(100.0 * COALESCE(SUM(s.quantity), 0) /
             (SELECT SUM(quantity) FROM inventory_stock), 2) AS pct_of_total
FROM product p
LEFT JOIN inventory_stock s ON s.product_id = p.product_id
GROUP BY p.product_id
ORDER BY stock_qty DESC;

-- 5.2 Підзапит-стовпець у WHERE (IN): товари, що постачались у скасованих накладних
SELECT p.sku_code,
       p.name
FROM product p
WHERE p.product_id IN (
    SELECT si.product_id
    FROM supply_item si
    JOIN supply_order o ON o.order_id = si.order_id
    WHERE o.status = 'cancelled'
)
ORDER BY p.sku_code;

-- 5.3 Табличний підзапит у FROM: товари, що є більше ніж в одній комірці, з середнім залишком
SELECT t.sku_code,
       t.avg_qty_per_location,
       t.locations_with_stock
FROM (
    SELECT p.sku_code,
           ROUND(AVG(s.quantity), 2) AS avg_qty_per_location,
           COUNT(s.location_id) AS locations_with_stock
    FROM product p
    LEFT JOIN inventory_stock s ON s.product_id = p.product_id
    GROUP BY p.product_id
) AS t
WHERE t.locations_with_stock > 1
ORDER BY t.avg_qty_per_location DESC;

-- 5.4 NOT EXISTS: товари, за якими не було жодного руху
SELECT p.sku_code,
       p.name
FROM product p
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory_movement m
    WHERE m.product_id = p.product_id
)
ORDER BY p.sku_code;

-- 5.5 Підзапит у HAVING: товари з залишком нижче середнього залишку по товарах
SELECT p.sku_code,
       COALESCE(SUM(s.quantity), 0) AS total_qty
FROM product p
LEFT JOIN inventory_stock s ON s.product_id = p.product_id
GROUP BY p.product_id
HAVING COALESCE(SUM(s.quantity), 0) < (
    SELECT AVG(prod_total)
    FROM (
        SELECT COALESCE(SUM(s2.quantity), 0) AS prod_total
        FROM product p2
        LEFT JOIN inventory_stock s2 ON s2.product_id = p2.product_id
        GROUP BY p2.product_id
    ) AS t
)
ORDER BY total_qty, p.sku_code;

-- 6. Багатотаблична агрегація

-- 6.1 Отримані постачання за постачальником: кількість накладних, позицій, обсяг, вартість
SELECT s.company_name,
       COUNT(DISTINCT o.order_id) AS received_orders,
       COUNT(si.product_id) AS item_lines,
       SUM(si.quantity) AS total_qty,
       SUM(si.quantity * si.unit_price) AS total_value
FROM supplier s
JOIN supply_order o ON o.supplier_id = s.supplier_id AND o.status = 'received'
JOIN supply_item si ON si.order_id = o.order_id
GROUP BY s.supplier_id
ORDER BY total_value DESC;

-- 6.2 Вартість прийнятих постачань за коміркою приймання
SELECT w.location_code,
       w.zone,
       COUNT(si.product_id) AS item_lines,
       SUM(si.quantity) AS total_qty,
       SUM(si.quantity * si.unit_price) AS total_value
FROM warehouse_location w
JOIN supply_item si ON si.location_id = w.location_id
JOIN supply_order o ON o.order_id = si.order_id AND o.status = 'received'
GROUP BY w.location_id
ORDER BY total_value DESC;

-- 6.3 Обсяг рухів за коміркою-відправником і типом руху
SELECT w.location_code AS from_location,
       m.movement_type,
       COUNT(*) AS ops_count,
       SUM(m.quantity) AS total_qty
FROM inventory_movement m
JOIN warehouse_location w ON w.location_id = m.from_location_id
GROUP BY w.location_id, m.movement_type
ORDER BY w.location_code, m.movement_type;

-- 7. Віконні функції (лекція 6)

-- 7.1 Рейтинг товарів за сумарним залишком (DENSE_RANK)
SELECT p.sku_code,
       COALESCE(SUM(s.quantity), 0) AS stock_qty,
       DENSE_RANK() OVER (ORDER BY COALESCE(SUM(s.quantity), 0) DESC) AS rnk
FROM product p
LEFT JOIN inventory_stock s ON s.product_id = p.product_id
GROUP BY p.product_id
ORDER BY rnk, p.sku_code;