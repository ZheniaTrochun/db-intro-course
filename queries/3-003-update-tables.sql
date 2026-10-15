-- 3.1 Завершити відкритий візит (visit_id = 12)
SELECT visit_id, ended_at FROM visit WHERE visit_id = 12;      -- до

UPDATE visit
SET ended_at = '2026-10-12 15:00:00'
WHERE visit_id = 12;

SELECT visit_id, ended_at FROM visit WHERE visit_id = 12;      -- після

-- 3.2 Змінити статус інциденту 6 на «У процесі»
SELECT incident_id, status_id FROM incident WHERE incident_id = 6;   -- до

UPDATE incident
SET status_id = (SELECT status_id FROM incident_status WHERE name = 'У процесі')
WHERE incident_id = 6;

SELECT incident_id, status_id FROM incident WHERE incident_id = 6;   -- після

-- 3.3 Змінити серйозність і опис тестового інциденту (кілька стовпців)
UPDATE incident
SET severity    = 'Середній',
    description = 'Тестовий інцидент (лаб. 3), оновлено'
WHERE description = 'Тестовий інцидент (лаб. 3)';

SELECT incident_id, severity, description
FROM incident
WHERE description LIKE 'Тестовий інцидент (лаб. 3)%';

-- 3.4 Змінити телефон співробітника
SELECT employee_id, phone FROM security_employee WHERE employee_id = 5;   -- до

UPDATE security_employee
SET phone = '+380501234599'
WHERE employee_id = 5;

SELECT employee_id, phone FROM security_employee WHERE employee_id = 5;   -- після