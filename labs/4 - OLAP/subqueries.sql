-- Запити з використанням підзапитів


-- 3.1. Підзапит у SELECT, виведення повітряних цілей та різниці їхньої швидкості від середньої
SELECT target_id, target_type, speed_kmh,
(SELECT ROUND(AVG(speed_kmh), 2) FROM air_target) AS avg_speed_all_targets,
speed_kmh - (SELECT ROUND(AVG(speed_kmh), 2) FROM air_target) AS speed_difference
FROM air_target;

-- 3.2. Підзапит у WHERE, цілі, що мають швидкість вищу за середню швидкість усіх дронів
SELECT target_id, target_type, speed_kmh, status
FROM air_target WHERE speed_kmh > (
SELECT AVG(speed_kmh) FROM air_target 
WHERE target_type = 'drone'
);

-- 3.3. Підзапит у HAVING, міста, середня відстань загрози в сповіщеннях для яких менша за середню відстань усіх сповіщень
SELECT c.name AS city_name,
ROUND(AVG(a.distance_km), 2) AS avg_alert_distance
FROM alert a 
JOIN subscription s ON a.subscription_id = s.subscription_id
JOIN city c ON s.city_id = c.city_id 
GROUP BY c.name
HAVING AVG(a.distance_km) < (SELECT AVG(distance_km) 
FROM alert
);