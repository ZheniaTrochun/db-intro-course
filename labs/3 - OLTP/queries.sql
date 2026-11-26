-- SELECT

-- виводимо назви та ціни всіх товарів
SELECT name, current_price
FROM product;

-- шукаємо товари дорожчі за 5000 грн
SELECT product_id, name, current_price
FROM product
WHERE current_price > 5000
ORDER BY current_price DESC;

-- шукаємо активні товари вартістю до 10000 грн
SELECT product_id, name, current_price
FROM product
WHERE current_price <= 10000 AND is_active = TRUE;

-- виводимо активні товари, які є на складі
SELECT product_id, name, stock_quantity
FROM product
WHERE is_active = TRUE AND stock_quantity > 0;

-- шукаємо товари, яких немає на складі
SELECT product_id, name, stock_quantity
FROM product
WHERE stock_quantity = 0;

-- виводимо покупців з ідентифікатором більшим за 3
SELECT costumer_id, full_name, email
FROM costumer
WHERE costumer_id > 3;

-- переглядаємо замовлення першого покупця
SELECT order_id, costumer_id, status, ordered_at
FROM costumer_order
WHERE costumer_id = 1;

-- шукаємо замовлення з Києва та Львова і додаємо імена покупців
SELECT o.order_id, c.full_name, o.delivery_city, o.status
FROM costumer_order o
JOIN costumer c ON c.costumer_id = o.costumer_id
WHERE o.delivery_city IN ('Київ', 'Львів')
ORDER BY o.order_id;

-- отримуємо категорії для кожного активного товару
SELECT p.product_id, p.name AS product_name, c.name AS category_name
FROM product p
JOIN product_category pc ON pc.product_id = p.product_id
JOIN category c ON c.category_id = pc.category_id
WHERE p.is_active = TRUE
ORDER BY p.product_id, c.name;

-- INSERT

BEGIN;

-- додаємо тестового покупця і перевіряємо результат
INSERT INTO costumer (full_name, email, phone)
VALUES ('Анна Коваль', 'anna.koval.lab3@example.com', '+380501234567')
ON CONFLICT (email) DO NOTHING;

SELECT costumer_id, full_name, email, phone, registered_at
FROM costumer
WHERE email = 'anna.koval.lab3@example.com';

-- додаємо тимчасову категорію для наступних UPDATE і DELETE
INSERT INTO category (name, description)
VALUES ('Тестова категорія Lab3', 'Категорія для перевірки INSERT')
ON CONFLICT (name) DO NOTHING;

SELECT category_id, name, description
FROM category
WHERE name = 'Тестова категорія Lab3';

COMMIT;

-- UPDATE

BEGIN;

-- виводимо старі дані товару, змінюємо ціну й залишок та перевіряємо результат
SELECT product_id, name, current_price, stock_quantity
FROM product
WHERE product_id = 1;

UPDATE product
SET current_price = 16000,
    stock_quantity = 12
WHERE product_id = 1;

SELECT product_id, name, current_price, stock_quantity
FROM product
WHERE product_id = 1;

-- оновлюємо опис тестової категорії та перевіряємо зміну
SELECT category_id, name, description
FROM category
WHERE name = 'Тестова категорія Lab3';

UPDATE category
SET description = 'Опис оновлено'
WHERE name = 'Тестова категорія Lab3';

SELECT category_id, name, description
FROM category
WHERE name = 'Тестова категорія Lab3';

COMMIT;

-- DELETE

BEGIN;

-- перевіряємо тестового покупця, видаляємо за email якщо для цього покупця не було створено ще жодного замовлення та перевіряємо результат
SELECT costumer_id, full_name, email
FROM costumer
WHERE email = 'anna.koval.lab3@example.com';

DELETE FROM costumer
WHERE email = 'anna.koval.lab3@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM costumer_order o
      WHERE o.costumer_id = costumer.costumer_id
  );

SELECT costumer_id, full_name, email
FROM costumer
WHERE email = 'anna.koval.lab3@example.com';

-- видаляємо лише тестову категорію, якщо вона не пов'язана з товарами
SELECT category_id, name, description
FROM category
WHERE name = 'Тестова категорія Lab3';

DELETE FROM category
WHERE name = 'Тестова категорія Lab3'
  AND NOT EXISTS (
      SELECT 1
      FROM product_category pc
      WHERE pc.category_id = category.category_id
  );

SELECT category_id, name, description
FROM category
WHERE name = 'Тестова категорія Lab3';

COMMIT;

-- перевіряємо, скільки записів залишилось у кожній таблиці
SELECT 'costumer' AS table_name, COUNT(*) AS row_count FROM costumer
UNION ALL
SELECT 'product', COUNT(*) FROM product
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'costumer_order', COUNT(*) FROM costumer_order
UNION ALL
SELECT 'order_item', COUNT(*) FROM order_item
UNION ALL
SELECT 'product_category', COUNT(*) FROM product_category
UNION ALL
SELECT 'payment', COUNT(*) FROM payment
UNION ALL
SELECT 'shipment', COUNT(*) FROM shipment;