-- агрнгатні ф-ції

-- загальна кількість замовлень
SELECT COUNT(*) AS total_orders
FROM costumer_order;

-- загальна кількість одиниць товарів на складі
SELECT SUM(stock_quantity) AS total_stock
FROM product;

-- середня, найменша та найбільша ціна товарів
SELECT AVG(current_price) AS average_price,
       MIN(current_price) AS min_price,
       MAX(current_price) AS max_price
FROM product;

-- GROUP BY та HAVING

-- кількість замовлень за містами доставки
SELECT delivery_city, COUNT(*) AS order_count
FROM costumer_order
GROUP BY delivery_city
ORDER BY delivery_city;

-- залишаємо міста, у яких оформлено хоча б два замовлення
SELECT delivery_city, COUNT(*) AS order_count
FROM costumer_order
GROUP BY delivery_city
HAVING COUNT(*) >= 2
ORDER BY order_count DESC;

-- JOIN

-- замовлення разом з іменами покупців
SELECT o.order_id, c.full_name, o.delivery_city, o.status
FROM costumer_order o
INNER JOIN costumer c ON o.costumer_id = c.costumer_id
ORDER BY o.order_id;

-- всі покупці, навіть якщо вони не мають замовлень
SELECT c.costumer_id, c.full_name, o.order_id
FROM costumer c
LEFT JOIN costumer_order o ON c.costumer_id = o.costumer_id
ORDER BY c.costumer_id, o.order_id;

-- виводимо всі товари, навіть якщо їх ще не замовляли
SELECT p.product_id, p.name, oi.order_id
FROM order_item oi
RIGHT JOIN product p ON oi.product_id = p.product_id
ORDER BY p.product_id, oi.order_id;

-- загальна вартість товарів у замовленнях кожного покупця
SELECT c.costumer_id, c.full_name,
       SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM costumer c
INNER JOIN costumer_order o ON c.costumer_id = o.costumer_id
INNER JOIN order_item oi ON o.order_id = oi.order_id
GROUP BY c.costumer_id, c.full_name
ORDER BY c.costumer_id;

-- підзапити

-- товари, дорожчі за середню ціну
SELECT product_id, name, current_price
FROM product
WHERE current_price > (
    SELECT AVG(current_price)
    FROM product
);

-- товари, які зустрічаються в замовленнях
SELECT product_id, name, current_price
FROM product
WHERE product_id IN (
    SELECT product_id
    FROM order_item
);

-- покупці, які ще не мають замовлень
SELECT c.costumer_id, c.full_name
FROM costumer c
WHERE NOT EXISTS (
    SELECT 1
    FROM costumer_order o
    WHERE o.costumer_id = c.costumer_id
);
