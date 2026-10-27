-- 1. агрегатні функції

-- кількість товарів
SELECT COUNT(*) AS total_products
FROM product;

-- кількість постачальників і скільки з них мають email
SELECT COUNT(*)     AS total_suppliers,
       COUNT(email) AS with_email
FROM supplier;

-- мінімальна, максимальна і середня ціна
SELECT MIN(unit_cost)           AS min_price,
       MAX(unit_cost)           AS max_price,
       ROUND(AVG(unit_cost), 2) AS avg_price
FROM movement_item;

-- скільки всього одиниць товару на всіх складах
SELECT SUM(quantity) AS total_units
FROM stock;

-- 2. Group By

-- кількість документів кожного типу
SELECT type,
       COUNT(*) AS documents
FROM movement
GROUP BY type
ORDER BY type;

-- кількість різних товарів і загальний залишок на кожному складі
SELECT warehouse_id,
       COUNT(*)      AS products,
       SUM(quantity) AS total_units
FROM stock
GROUP BY warehouse_id
ORDER BY warehouse_id;

-- 3. Фільтрія (Having)

-- товари, яких на всіх складах разом більше 10 штук
SELECT product_id,
       SUM(quantity) AS total_units
FROM stock
GROUP BY product_id
HAVING SUM(quantity) > 10
ORDER BY total_units DESC;

-- 4. операції JOIN

-- INNER JOIN: документи руху (ттн) з назвою складу
SELECT m.document_no,
       m.type,
       w.name AS warehouse,
       m.occurred_at
FROM movement m
INNER JOIN warehouse w ON w.warehouse_id = m.warehouse_id
ORDER BY m.occurred_at;

-- LEFT JOIN: усі постачальники та їхні документи (навіть якщо документів немає)
SELECT s.name AS supplier,
       m.document_no,
       m.occurred_at
FROM supplier s
LEFT JOIN movement m ON m.supplier_id = s.supplier_id
ORDER BY s.supplier_id;

-- CROSS JOIN: кожен склад з кожним товаром, залишок 0 якщо товару немає
SELECT w.name AS warehouse,
       p.name AS product,
       COALESCE(st.quantity, 0) AS quantity
FROM warehouse w
CROSS JOIN product p
LEFT JOIN stock st ON st.warehouse_id = w.warehouse_id
                  AND st.product_id = p.product_id
ORDER BY w.warehouse_id, p.product_id;

-- 5. об'єднані запити

-- на яку суму і скільки штук поставив кожен постачальник
SELECT s.name                         AS supplier,
       SUM(mi.quantity)               AS units,
       SUM(mi.quantity * mi.unit_cost) AS total_cost
FROM supplier s
JOIN movement m       ON m.supplier_id  = s.supplier_id
JOIN movement_item mi ON mi.movement_id = m.movement_id
GROUP BY s.name
ORDER BY total_cost DESC;

-- скільки штук товару кожної категорії на всіх складах
SELECT c.name           AS category,
       SUM(st.quantity) AS total_units
FROM category c
JOIN product p ON p.category_id = c.category_id
JOIN stock st  ON st.product_id = p.product_id
GROUP BY c.name
ORDER BY total_units DESC;

-- 6. Підзапити

-- підзапит у WHERE: товар з найнижчою закупівельною ціною
SELECT p.name AS product,
       mi.unit_cost
FROM movement_item mi
JOIN product p ON p.product_id = mi.product_id
WHERE mi.unit_cost = (SELECT MIN(unit_cost) FROM movement_item);

-- підзапит у SELECT: скільки документів оформлено на кожному складі
SELECT w.name AS warehouse,
       (SELECT COUNT(*)
        FROM movement m
        WHERE m.warehouse_id = w.warehouse_id) AS documents
FROM warehouse w
ORDER BY w.warehouse_id;

-- підзапит у HAVING: товари, яких на складах менше, ніж надійшло (були списання)
SELECT p.name           AS product,
       SUM(st.quantity) AS in_stock
FROM product p
JOIN stock st ON st.product_id = p.product_id
GROUP BY p.product_id, p.name
HAVING SUM(st.quantity) < (
    SELECT SUM(mi.quantity)
    FROM movement_item mi
    JOIN movement m ON m.movement_id = mi.movement_id
    WHERE m.type = 'receipt'
      AND mi.product_id = p.product_id
)
ORDER BY p.product_id;