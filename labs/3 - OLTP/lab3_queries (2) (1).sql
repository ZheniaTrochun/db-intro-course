-- Каталог товарів

INSERT INTO author (first_name, last_name, country)
VALUES ('Данило', 'Кравчук', 'Україна');

SELECT * FROM author WHERE first_name = 'Данило';

SELECT title, publication_year, price
FROM book
WHERE price > 400;

SELECT * FROM book;

UPDATE book
SET price = 1450, stock_quantity = 12
WHERE book_id = 1;

SELECT * FROM book WHERE book_id = 1;

SELECT * FROM category;

DELETE FROM category
WHERE name_category = 'Фентезі';

SELECT * FROM category;

-- Клієнти та замовлення

INSERT INTO Book DEFAULT VALUES;
INSERT INTO Book DEFAULT VALUES;
INSERT INTO Book DEFAULT VALUES;
INSERT INTO Book DEFAULT VALUES;

INSERT INTO OrderItem (OrderID, BookID, Quantity, PriceAtPurchase) VALUES
(1, 1, 1, 300.00),
(1, 2, 1, 250.00),
(2, 3, 1, 450.00),
(3, 4, 1, 350.00);

INSERT INTO orders (CustomerID, Status, ShippingAddress, TotalAmount) VALUES
(1, 'Оплачено',        'Київ, вул. Хрещатик 1',   350.00),
(2, 'Очікує обробки',  'Львів, пл. Ринок 2',      450.00),
(3, 'Доставлено',      'Київ, вул. Дніпровська 3', 300.00),
(4, 'Відправлено',     'Одеса, вул. Морська 4',    300.00);

SELECT FirstName, LastName, Email
FROM Customer
WHERE ShippingAddressDefault LIKE '%Київ%';

SELECT OrderID, CustomerID, TotalAmount
FROM orders
WHERE Status = 'Очікує обробки';

UPDATE orders
SET Status = 'Відправлено'
WHERE OrderID = 2;

SELECT OrderID, CustomerID, Status, TotalAmount
FROM orders
WHERE OrderID = 2;

DELETE FROM Customer
WHERE Email = 'test@test.com';

SELECT *
FROM Customer
WHERE Email = 'test@test.com';

-- Відгуки та оцінка

SELECT * FROM review;

INSERT INTO review (customer_id, book_id, order_item_id, rating, comment)
VALUES (3, 4, 4, 5, 'Чудова книга для всієї родини, швидка доставка.');

INSERT INTO review (customer_id, book_id, order_item_id, rating, comment)
VALUES (4, 1, NULL, 3, 'Корисна книга, але складна для початківців.');

SELECT * FROM review ORDER BY review_id;

SELECT review_id, customer_id, book_id, rating
FROM review
WHERE rating = 5;

SELECT review_id, book_id, rating, comment
FROM review
WHERE customer_id = 1;

SELECT * FROM review WHERE customer_id = 3 AND book_id = 4;

UPDATE review
SET rating = 4,
    comment = 'Гарна книга, але хотілося б щільнішу обкладинку.'
WHERE customer_id = 3 AND book_id = 4;

SELECT * FROM review WHERE customer_id = 3 AND book_id = 4;

DELETE FROM review
WHERE customer_id = 4 AND book_id = 1;

SELECT * FROM review WHERE customer_id = 4 AND book_id = 1;
SELECT * FROM review ORDER BY review_id;
