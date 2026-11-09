-- Лабораторна робота №3. Інтернет-магазин.

-- 1. Перегляд клієнтів, додавання, зміна і видалення клієнта.

BEGIN;

-- Вибір потрібних стовпців.
SELECT customer_id, first_name, last_name, email
FROM customer;

-- Фільтрація клієнтів за прізвищем.
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE last_name = 'Коваль';

-- Додавання нового клієнта.
INSERT INTO customer (first_name, last_name, email, phone)
VALUES ('Марія', 'Савченко', 'maria.lab3@example.com', '+380501234567');

-- Перевірка доданого запису перед його зміною.
SELECT customer_id, first_name, last_name, email, phone
FROM customer
WHERE email = 'maria.lab3@example.com';

-- Зміна номера телефону конкретного клієнта.
UPDATE customer
SET phone = '+380671234567'
WHERE email = 'maria.lab3@example.com';

-- Перевірка оновленого номера.
SELECT customer_id, first_name, last_name, email, phone
FROM customer
WHERE email = 'maria.lab3@example.com';

-- Видалення створеного клієнта, який не має залежних записів.
DELETE FROM customer
WHERE email = 'maria.lab3@example.com';

-- Після видалення запит повинен повернути 0 рядків.
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE email = 'maria.lab3@example.com';

COMMIT;