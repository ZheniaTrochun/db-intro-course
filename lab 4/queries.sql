SELECT COUNT(*) AS booking_count,
       MIN(total_price) AS min_price,
       MAX(total_price) AS max_price
FROM booking
WHERE status <> 'cancelled';

SELECT payment_method,
       COUNT(*) AS payment_count,
       SUM(amount) AS total_amount
FROM payment
WHERE status = 'success'
GROUP BY payment_method
ORDER BY payment_method;

SELECT payment_method,
       COUNT(*) AS payment_count,
       SUM(amount) AS total_amount
FROM payment
WHERE status = 'success'
GROUP BY payment_method
HAVING COUNT(*) > 1
ORDER BY payment_method;

SELECT court.court_id, court.court_name,
       AVG(booking.total_price) AS average_booking_price
FROM court
INNER JOIN booking ON court.court_id = booking.court_id
WHERE booking.status <> 'cancelled'
GROUP BY court.court_id, court.court_name
ORDER BY court.court_id;

SELECT booking.booking_id, booking.booking_date, client.first_name, client.last_name
FROM booking
INNER JOIN client ON booking.client_id = client.client_id
ORDER BY booking.booking_id;

SELECT booking.booking_id, coach.first_name, coach.last_name
FROM booking
LEFT JOIN coach ON booking.coach_id = coach.coach_id
ORDER BY booking.booking_id;

SELECT court.court_name, booking.booking_id, booking.booking_date
FROM booking
RIGHT JOIN court ON booking.court_id = court.court_id
ORDER BY court.court_id, booking.booking_id;

SELECT booking_id, total_price
FROM booking
WHERE status <> 'cancelled'
  AND total_price > (
      SELECT AVG(total_price)
      FROM booking
      WHERE status <> 'cancelled'
  )
ORDER BY booking_id;

SELECT booking_id, booking_date
FROM booking
WHERE booking_id IN (
    SELECT booking_id
    FROM payment
    WHERE status = 'success'
)
ORDER BY booking_id;

SELECT client_id, first_name, last_name
FROM client
WHERE NOT EXISTS (
    SELECT 1
    FROM booking
    WHERE booking.client_id = client.client_id
)
ORDER BY client_id;