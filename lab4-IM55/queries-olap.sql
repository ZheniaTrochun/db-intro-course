-- Варенко Катерина
-- 1.1
SELECT COUNT(*) AS total_customers
FROM customer;

-- 1.2
SELECT a.city, COUNT(o.id) AS orders_count
FROM address a
JOIN orders o ON o.address_id = a.id
GROUP BY a.city
ORDER BY orders_count DESC;

-- 1.3
SELECT c.first_name, c.last_name, a.street, a.city, a.postal_code
FROM customer c
INNER JOIN address a ON a.customer_id = c.id
ORDER BY c.id;

-- 1.4
SELECT customer_id, COUNT(*) AS order_count
FROM orders
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)
GROUP BY customer_id
ORDER BY order_count DESC;

-- Поліщук Анна
-- 2.1
SELECT COUNT(*) AS total_books, AVG(price) AS avg_price
FROM book;

-- 2.2
SELECT c.category_name, COUNT(bc.book_id) AS books_count
FROM category c
JOIN book_category bc ON bc.category_id = c.category_id
GROUP BY c.category_name
HAVING COUNT(bc.book_id) > 1
ORDER BY books_count DESC;

-- 2.3
SELECT b.title, c.category_name
FROM book b
INNER JOIN book_category bc ON bc.book_id = b.id
INNER JOIN category c       ON c.id = bc.category_id
ORDER BY b.title;

-- 2.4
SELECT title, price
FROM book
WHERE price > (SELECT AVG(price) FROM book)
ORDER BY price DESC;

-- Лобода Аліна
-- 3.1
SELECT COUNT(*) AS total_orders, MIN(date) AS first_order, MAX(date) AS last_order
FROM orders;

-- 3.2
SELECT status, COUNT(*) AS orders_count
FROM orders
GROUP BY status
ORDER BY orders_count DESC, status;

-- 3.3
SELECT o.id AS order_id, o.date, o.status,
       c.first_name || ' ' || c.last_name AS customer,
       a.city, p.amount, p.method
FROM orders o
INNER JOIN customer c ON c.id = o.customer_id
INNER JOIN address a ON a.id = o.address_id
INNER JOIN payment p ON p.order_id = o.id
ORDER BY o.id;

-- 3.4
SELECT id, customer_id, date, status
FROM orders
WHERE id IN (
    SELECT order_id
    FROM payment
    WHERE status = 'очікує'
)
ORDER BY id;

-- Сітковська Аліна
-- 4.1
SELECT COUNT(*) AS payments_count,
       SUM(amount) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount,
       MIN(amount) AS min_amount,
       MAX(amount) AS max_amount
FROM payment;

-- 4.2
SELECT method, SUM(amount) AS total_amount
FROM payment
GROUP BY method
HAVING SUM(amount) > 1000;

-- 4.3
SELECT cat.category_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM category cat
JOIN book_category bc ON bc.category_id = cat.id
JOIN order_item oi ON oi.book_id = bc.book_id
GROUP BY cat.id, cat.category_name
ORDER BY revenue DESC;

-- 4.4
SELECT o.id AS order_id,
       (SELECT SUM(oi.quantity * oi.unit_price)
        FROM order_item oi
        WHERE oi.order_id = o.id) AS items_total,
       (SELECT p.amount
        FROM payment p
        WHERE p.order_id = o.id) AS paid_amount
FROM orders o
ORDER BY o.id;