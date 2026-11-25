-- 1. Базова агрегація (без групування)
select
count(order_id) as total_orders,
round(avg(total_amount), 2) as avg_order_amount,
min(total_amount) as min_order_amount,
max(total_amount) as max_order_amount
from orders;

-- 2. Групування (GROUP BY)
select status,
count(order_id) as orders_count,
sum(total_amount) as total_revenue
from orders
group by status;

-- 3. INNER JOIN
select b.title,
       b.isbn,
       b.price,
       p.name_publisher
from book b
inner join publisher p on b.publisher_id = p.publisher_id
where b.price > 350;

-- 4. Підзапит у WHERE
select book_id, title, isbn, price
from book
where price > (select avg(price) from book);

-- 1. Фільтрування груп (HAVING)
SELECT cat.name_category, ROUND(AVG(b.price), 2) AS avg_price
FROM category cat
JOIN book_category bc ON bc.category_id = cat.category_id
JOIN book b ON b.book_id = bc.book_id
GROUP BY cat.category_id, cat.name_category
HAVING AVG(b.price) > 400;

-- 2. LEFT JOIN
SELECT c.first_name, c.last_name, c.email, COUNT(o.order_id) AS orders_count
FROM customer c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- 3. Підзапит у SELECT
SELECT title, price,
       (SELECT ROUND(AVG(price), 2) FROM book) AS avg_price
FROM book;

-- 1. Багатотаблична агрегація
SELECT publisher.name_publisher, SUM(order_item.quantity) AS total_sold
FROM publisher
JOIN book ON publisher.publisher_id = book.publisher_id
JOIN order_item ON book.book_id = order_item.book_id
GROUP BY publisher.name_publisher;

-- 2. FULL JOIN
SELECT customer.first_name, customer.last_name, review.rating, review.comment
FROM customer
FULL JOIN review ON customer.customer_id = review.customer_id;

-- 3. Підзапит у FROM
SELECT temp.customer_id, temp.total_spent
FROM (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
) AS temp
WHERE temp.total_spent > 500;
