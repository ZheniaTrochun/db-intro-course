-- 1.1 Перегляд усіх студентів
-- Мета: перевірити, що дані завантажені. Очікується: 12 рядків.
SELECT * FROM student;

-- 1.2 Лише потрібні стовпці + WHERE
-- Мета: студенти групи 52. Очікується: 11 рядків.
SELECT student_id, full_name
FROM student
WHERE group_id = 52;

-- 1.3 Інциденти з високою серйозністю
-- Очікується: 2 рядки (ID 4 і 6).
SELECT incident_id, description, occurred_at, severity
FROM incident
WHERE severity = 'Високий';

-- 1.4 Візити, які ще не завершилися
-- Очікується: 1 рядок (visit_id = 12).
SELECT visit_id, student_id, category, started_at
FROM visit
WHERE ended_at IS NULL;

-- 1.5 Пошук за частиною тексту
-- Очікується: інциденти, де в описі є слово «лавк».
SELECT incident_id, description
FROM incident
WHERE description ILIKE '%лавк%';

-- 1.6 Сортування і обмеження
-- Мета: 3 найновіші інциденти.
SELECT incident_id, occurred_at, severity
FROM incident
ORDER BY occurred_at DESC
LIMIT 3;

-- 1.7 JOIN: інциденти з типом, статусом та співробітником
-- Очікується: 7 рядків.
SELECT i.incident_id,
       t.name        AS incident_type,
       s.name        AS status,
       e.full_name   AS employee,
       i.severity,
       i.occurred_at
FROM incident i
JOIN incident_type     t ON t.type_id     = i.type_id
JOIN incident_status   s ON s.status_id   = i.status_id
JOIN security_employee e ON e.employee_id = i.employee_id
ORDER BY i.incident_id;

-- 1.8 JOIN: учасники інцидентів з іменами студентів та ролями
-- Очікується: 10 рядків.
SELECT ip.incident_id,
       st.full_name AS student,
       r.name       AS role
FROM incident_participant ip
JOIN visit            v  ON v.visit_id   = ip.visit_id
JOIN student          st ON st.student_id = v.student_id
JOIN participant_role r  ON r.role_id    = ip.role_id
ORDER BY ip.incident_id, st.full_name;

-- 1.9 Інциденти конкретного студента
-- Очікується: інциденти студента «Марчук Олег Олександрович» (як учасника).
SELECT ip.incident_id, i.description, r.name AS role
FROM student st
JOIN visit v                 ON v.student_id = st.student_id
JOIN incident_participant ip ON ip.visit_id  = v.visit_id
JOIN incident i              ON i.incident_id = ip.incident_id
JOIN participant_role r      ON r.role_id    = ip.role_id
WHERE st.full_name = 'Марчук Олег Олександрович';