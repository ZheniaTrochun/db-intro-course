
-- 1. Функції агрегації

-- 1.1. Підрахування загальної кількості клієнтів
SELECT COUNT(*) AS total_customers
FROM customer;

-- 1.2. Підрахування загальної кількості успішно оплачених платежів
SELECT COUNT(*) AS total_paid
FROM payment
WHERE status = 'paid';

-- 1.3. Обчислення загальної суми успішно оплачених платежів
SELECT SUM(amount) AS total_amount_of_paid
FROM payment
WHERE status = 'paid';

-- 1.4. Обчислення середньої вартості оренди автомобілів за день
SELECT AVG(daily_rate) AS average_daily_rate
FROM car_model;

-- 1.5. Визначення мінімальної та максимальної вартості оренди
SELECT MIN(price) AS min_rental_price, MAX(price) AS max_rental_price
FROM rental;



-- 2. GROUP BY  та  HAVING

-- 2.1. Виведення статусів оренди, де кількість оренд більша за одну
SELECT status, COUNT(*) AS total_rentals
FROM rental
GROUP BY status
HAVING COUNT(*) > 1;



-- 3. JOIN

-- 3.1. Виведення інформації про оренди та їхніх клієнтів
SELECT c.customer_id, c.first_name, c.last_name,
       r.rental_id, r.start_date, r.end_date, r.price, r.status
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id;


-- 3.2. Виведення всіх клієнтів та інформації про їхні оренди
SELECT c.customer_id, c.first_name, c.last_name,
       r.rental_id, r.status
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id;


-- 3.3. Виведення всіх оренд та інформації про платежі
SELECT r.rental_id, r.status AS rental_status,
       p.payment_id, p.amount, p.status AS payment_status
FROM payment p
RIGHT JOIN rental r ON p.rental_id = r.rental_id;



-- 4. Підзапити

-- 4.1. Виведення оренд, де вартість більша за середню вартість усіх оренд
SELECT rental_id, customer_id, price, status
FROM rental
WHERE price > (
    SELECT AVG(price)
    FROM rental
);


-- 4.2. Виведення моделей автомобілів та їх середньої вартості оренди за день
SELECT brand, model, daily_rate,
       (SELECT AVG(daily_rate) FROM car_model) AS average_daily_rate
FROM car_model;


-- 4.3. Виведення клієнтів, які мають більше однієї оренди
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(*) > 1
);

