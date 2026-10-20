-- 1.1 Загальна статистика по інцидентах
SELECT COUNT(*)         AS total_incidents,
       MIN(occurred_at) AS first_incident,
       MAX(occurred_at) AS last_incident
FROM incident;

-- 1.2 Кількість інцидентів за рівнем серйозності
SELECT severity, COUNT(*) AS incident_count
FROM incident
GROUP BY severity
ORDER BY incident_count DESC;

-- 1.3 Тривалість завершених візитів за категорією
SELECT category,
       COUNT(*)                    AS visits_count,
       AVG(ended_at - started_at)  AS avg_duration,
       MIN(ended_at - started_at)  AS min_duration,
       MAX(ended_at - started_at)  AS max_duration
FROM visit
WHERE ended_at IS NOT NULL
GROUP BY category;

-- 1.4 HAVING: типи інцидентів, які траплялися щонайменше 3 рази
SELECT it.name AS incident_type, COUNT(*) AS incident_count
FROM incident i
JOIN incident_type it ON it.type_id = i.type_id
GROUP BY it.name
HAVING COUNT(*) >= 3
ORDER BY incident_count DESC;

-- 1.5 Багатотаблична агрегація: візити та інциденти по факультетах
SELECT s.faculty_id,
       COUNT(DISTINCT v.visit_id)    AS visits_count,
       COUNT(DISTINCT i.incident_id) AS incidents_count
FROM student s
JOIN visit v         ON v.student_id = s.student_id
LEFT JOIN incident i ON i.visit_id = v.visit_id
GROUP BY s.faculty_id
ORDER BY s.faculty_id;