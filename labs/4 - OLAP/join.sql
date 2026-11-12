-- Запити з використанням різних типів JOIN


-- 2.1. INNER JOIN, деталізований звіт про згенеровані сповіщення
SELECT u.full_name AS user_name, c.name AS city_name,
t.target_type, a.threat_level, a.distance_km, a.delivery_status
FROM alert a
INNER JOIN subscription s ON a.subscription_id = s.subscription_id
INNER JOIN user_account u ON s.user_id = u.user_id
INNER JOIN city c ON s.city_id = c.city_id
INNER JOIN air_target t ON a.target_id = t.target_id;

-- 2.2. LEFT JOIN, усі користувачі та їхні підписки
SELECT u.full_name, u.email, s.subscription_id, 
c.name AS subscribed_city, s.is_active
FROM user_account u
LEFT JOIN subscription s ON u.user_id = s.user_id
LEFT JOIN city c ON s.city_id = c.city_id;

-- 2.3. RIGHT JOIN, усі джерела даних та виявлені ними цілі
SELECT  ds.name AS source_name, 
ds.source_kind, t.target_id, t.target_type,
t.status AS target_status
FROM air_target t
RIGHT JOIN data_source ds ON t.source_id = ds.source_id;