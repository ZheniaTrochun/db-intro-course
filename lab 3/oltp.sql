SELECT court_id, court_name, hourly_rate
FROM court
WHERE surface_type = 'hard'
  AND hourly_rate <= 600.00
ORDER BY hourly_rate, court_id;

SELECT booking_id, booking_date, start_time, end_time, status
FROM booking
WHERE court_id = 3
ORDER BY booking_date, start_time;

BEGIN;

INSERT INTO client (first_name, last_name, email)
VALUES ('Анна', 'Доценко', 'annd@gmail.com');

SELECT client_id, first_name, last_name, phone, email
FROM client
WHERE email = 'annd@gmail.com';

UPDATE client
SET phone = '+380994826161'
WHERE email = 'annd@gmail.com';

SELECT client_id, first_name, last_name, phone, email
FROM client
WHERE email = 'annd@gmail.com';

DELETE FROM client
WHERE email = 'annd@gmail.com';

SELECT client_id, first_name, last_name, phone, email
FROM client
WHERE email = 'annd@gmail.com';

ROLLBACK;