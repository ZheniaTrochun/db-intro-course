-- Базова агрегація та групування


-- 1.1. Базова агрегація, загальна статистика щодо повітряних цілей
SELECT COUNT(*) AS total_targets,
ROUND(AVG(speed_kmh), 2) AS avg_speed_kmh,
MIN(speed_kmh) AS min_speed_kmh,
MAX(speed_kmh) AS max_speed_kmh
FROM air_target;

-- 1.2. Групування, кількість сповіщень за статусом доставки
SELECT delivery_status, COUNT(*) AS alert_count
FROM alert 
GROUP BY delivery_status;

-- 1.3. Групування, розподіл цілей за типом та середня швидкість
SELECT target_type, COUNT(*) AS total_count, 
ROUND(AVG(speed_kmh), 2) AS avg_speed
FROM air_target
GROUP BY target_type
ORDER BY total_count DESC;

-- 1.4. Фільтрація груп, джерела даних з середньою надійністю вище 3 та щонайменше 2 цілями
SELECT ds.source_id, ds.name AS source_name,
COUNT(t.target_id) AS total_targets_detected,
AVG(ds.reliability) AS avg_reliability
FROM data_source ds
JOIN air_target t ON ds.source_id = t.source_id
GROUP BY ds.source_id, ds.name
HAVING AVG(ds.reliability) >= 4.0;