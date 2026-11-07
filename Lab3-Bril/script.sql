-- 1. SELECT

-- 1.1. Виведення інформацію про клієнтів
SELECT customer_id, first_name, last_name, email FROM customer;

-- 1.2. Виведення переліку моделей позашляховиків(SUV)
SELECT brand, model, category, daily_rate FROM car_model 
WHERE category = 'SUV';

-- 1.3. Виведення переліку доступних автомобілів
SELECT car_id, car_model_id, status FROM car
WHERE status = 'available';

-- 1.4. Виведення переліку завершених оренд
SELECT rental_id, customer_id, car_id, start_date, end_date, price FROM rental
WHERE status = 'finished';

-- 1.5. Виведення переліку успішно оплачених платежів
SELECT payment_id, rental_id, amount, payment_date FROM payment
WHERE status = 'paid';

-- 1.6. Виведення оренд вартістю понад 20000
SELECT rental_id, customer_id, car_id, price, status FROM rental
WHERE price > 20000;



-- 2. INSERT

-- 2.1. Додавання нового клієнта
INSERT INTO customer (first_name, last_name, email, phone, address)
VALUES ('Oleg', 'Golubkov', 'customer.lab3@gmail.com', '+380991112233', 'Kyiv...');

-- Перевірка 2.1
SELECT customer_id, first_name, last_name, email FROM customer
WHERE email = 'customer.lab3@gmail.com';

-- 2.2. Додавання нової моделі автомобіля
INSERT INTO car_model (brand, model, category, description, daily_rate)
VALUES ('Volvo', 'XC90', 'SUV', 'Premium family SUV...', 6500.00);

-- Перевірка 2.2
SELECT brand, model, category, daily_rate FROM car_model
WHERE brand = 'Volvo' AND model = 'XC90';

-- 2.3. Додавання нового автомобіля
INSERT INTO car (car_model_id, status)
VALUES ((SELECT car_model_id FROM car_model
    WHERE brand = 'Volvo' AND model = 'XC90'), 'available');

-- Перевірка 2.3
SELECT car_id, car_model_id, status FROM car
WHERE car_model_id = (SELECT car_model_id FROM car_model
    WHERE brand = 'Volvo' AND model = 'XC90');



-- 3. UPDATE

-- 3.1. Зміна номера телефону клієнта
UPDATE customer
SET phone = '+380671234567'
WHERE email = 'customer.lab3@gmail.com';

-- Перевірка 3.1
SELECT customer_id, first_name, last_name, email, phone FROM customer
WHERE email = 'customer.lab3@gmail.com';

-- 3.2. Зміна декількох характеристик моделі автомобіля
UPDATE car_model
SET daily_rate = 7000.00,
    description = 'Updated premium family SUV...'
WHERE brand = 'Volvo' AND model = 'XC90';

-- Перевірка 3.2
SELECT brand, model, description, daily_rate FROM car_model
WHERE brand = 'Volvo' AND model = 'XC90';

-- 3.3. Зміна статусу автомобіля
UPDATE car
SET status = 'maintenance'
WHERE car_model_id = (SELECT car_model_id FROM car_model
    WHERE brand = 'Volvo' AND model = 'XC90');

-- Перевірка 3.3
SELECT car_id, car_model_id, status
FROM car
WHERE car_model_id = (SELECT car_model_id FROM car_model
    WHERE brand = 'Volvo' AND model = 'XC90');



-- 4. DELETE

-- 4.1. Видалення тестового автомобіля
DELETE FROM car
WHERE car_model_id = (SELECT car_model_id FROM car_model
    WHERE brand = 'Volvo' AND model = 'XC90');

-- Перевірка 4.1
SELECT car_id, car_model_id, status FROM car
WHERE car_model_id = (SELECT car_model_id FROM car_model
    WHERE brand = 'Volvo' AND model = 'XC90');

-- 4.2. Видалення тестової моделі автомобіля
DELETE FROM car_model
WHERE brand = 'Volvo' AND model = 'XC90';

-- Перевірка 4.2
SELECT brand, model, category, daily_rate FROM car_model
WHERE brand = 'Volvo' AND model = 'XC90';

-- 4.3. Видалення тестового клієнта
DELETE FROM customer
WHERE email = 'customer.lab3@gmail.com';

-- Перевірка 4.3
SELECT customer_id, first_name, last_name, email FROM customer
WHERE email = 'customer.lab3@gmail.com';



-- 5. TRANSACTIONS

-- Використання транзакцій
BEGIN;

-- Додавання тестового клієнта
INSERT INTO customer (first_name, last_name, email, phone, address)
VALUES ('Andrew', 'Apple', 'transaction.lab3@gmail.com', '+380991234777', 'Kyiv...');

-- Перевірка запису всередині транзакції
SELECT customer_id, first_name, last_name, email FROM customer
WHERE email = 'transaction.lab3@gmail.com';

-- Скасування змін
ROLLBACK;

-- Перевірка після скасування
SELECT customer_id, first_name, last_name, email FROM customer
WHERE email = 'transaction.lab3@gmail.com';

-- Початок нової транзакції
BEGIN;

-- Додавання тестового клієнта
INSERT INTO customer (first_name, last_name, email, phone, address)
VALUES ('Andrew', 'Apple', 'transaction.lab3@gmail.com', '+380991234657', 'Kyiv...');

-- Підтвердження змін
COMMIT;

-- Перевірка після підтвердження транзакції
SELECT customer_id, first_name, last_name, email FROM customer
WHERE email = 'transaction.lab3@gmail.com';

-- Видалення тестового клієнта
DELETE FROM customer
WHERE email = 'transaction.lab3@gmail.com';