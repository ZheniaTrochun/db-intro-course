-- 1. Базова агрегація. Загальний виторг, чистий прибуток та середній чек
SELECT 
    COUNT(*) AS total_payments,
    SUM(total_amount) AS gross_revenue,
    SUM(net_profit) AS total_net_profit,
    ROUND(AVG(total_amount), 2) AS average_bill,
    MIN(total_amount) AS min_bill,
    MAX(total_amount) AS max_bill
FROM Payment;


-- 2. Групування даних. Кількість сеансів та розподіл за статусами (Scheduled, Completed, Cancelled)
SELECT 
    status, 
    COUNT(*) AS total_sessions
FROM Session
GROUP BY status;


-- 3. Фільтрування груп: Аналіз популярності послуг за кількістю записів
SELECT 
    s.name AS service_name, 
    COUNT(ses.session_id) AS booking_count
FROM Service s
JOIN Session ses ON s.service_id = ses.service_id
GROUP BY s.name
HAVING COUNT(ses.session_id) >= 1
ORDER BY booking_count DESC;


-- 4. INNER JOIN. журнал записів (Client + Session + Service)
SELECT 
    c.full_name, 
    c.phone_number, 
    s.name AS service_name, 
    ses.session_date, 
    ses.start_time, 
    ses.status
FROM Session ses
INNER JOIN Client c ON ses.client_id = c.client_id
INNER JOIN Service s ON ses.service_id = s.service_id
ORDER BY ses.session_date, ses.start_time;


-- 5. Багатотаблична агрегація. розрахунок показника total_waste (собівартість витратників за сеанс)
SELECT 
    ses.session_date,
    c.full_name AS client_name,
    COUNT(a.additional_service_id) AS items_count,
    SUM(a.cost * a.quantity) AS total_waste
FROM Additional_Service a
JOIN Session ses ON a.session_id = ses.session_id
JOIN Client c ON ses.client_id = c.client_id
GROUP BY ses.session_id, ses.session_date, c.full_name;


-- 6. LEFT JOIN. Розрахунок LTV (довічної цінності) клієнтів згідно зі зв'язком Client-Payment
SELECT 
    c.full_name, 
    c.phone_number, 
    COALESCE(SUM(p.total_amount), 0.00) AS total_spent_ltv,
    COALESCE(SUM(p.net_profit), 0.00) AS client_net_profit
FROM Client c
LEFT JOIN Payment p ON c.client_id = p.client_id
GROUP BY c.client_id, c.full_name, c.phone_number
ORDER BY total_spent_ltv DESC;


-- 7. FULL OUTER JOIN. Фінансовий аудит відповідності сеансів та оплат (one-to-one)
SELECT 
    ses.session_date,
    ses.status,
    p.payment_id,
    p.total_amount,
    p.net_profit
FROM Session ses
FULL OUTER JOIN Payment p ON ses.session_id = p.session_id;


-- 8. Підзапит у SELECT. Відхилення базової вартості послуги від середньої по прайсу
SELECT 
    name, 
    base_price,
    ROUND((SELECT AVG(base_price) FROM Service), 2) AS catalog_avg_price,
    ROUND(base_price - (SELECT AVG(base_price) FROM Service), 2) AS price_diff
FROM Service;


-- 9. Підзапит у WHERE. Сеанси з оплатою, що перевищує середній платіж по системі
SELECT 
    c.full_name, 
    p.total_amount, 
    p.net_profit, 
    p.payment_time
FROM Payment p
JOIN Client c ON p.client_id = c.client_id
WHERE p.total_amount > (SELECT AVG(total_amount) FROM Payment);


-- 10. Підзапит у HAVING. Послуги, сумарний виторг від яких вищий за середній виторг на послугу
SELECT 
    s.name AS service_name, 
    SUM(p.total_amount) AS service_gross_revenue
FROM Service s
JOIN Session ses ON s.service_id = ses.service_id
JOIN Payment p ON ses.session_id = p.session_id
GROUP BY s.name
HAVING SUM(p.total_amount) >= (
    SELECT AVG(service_total) 
    FROM (
        SELECT SUM(p2.total_amount) AS service_total
        FROM Session ses2
        JOIN Payment p2 ON ses2.session_id = p2.session_id
        GROUP BY ses2.service_id
    ) sub
);