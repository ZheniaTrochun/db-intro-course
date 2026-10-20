-- 2.1 INNER JOIN: повна інформація про інцидент
SELECT i.incident_id,
       s.full_name   AS student,
       it.name       AS incident_type,
       ist.name      AS status,
       se.full_name  AS security_employee,
       i.severity,
       i.occurred_at
FROM incident i
JOIN visit v              ON v.visit_id    = i.visit_id
JOIN student s            ON s.student_id  = v.student_id
JOIN incident_type it     ON it.type_id    = i.type_id
JOIN incident_status ist  ON ist.status_id = i.status_id
JOIN security_employee se ON se.employee_id = i.employee_id
ORDER BY i.occurred_at DESC;

-- 2.2 LEFT JOIN: усі студенти та кількість їхніх візитів (включно з 0)
SELECT s.student_id, s.full_name, COUNT(v.visit_id) AS visits_count
FROM student s
LEFT JOIN visit v ON v.student_id = s.student_id
GROUP BY s.student_id, s.full_name
ORDER BY visits_count DESC;

-- 2.3 LEFT JOIN + IS NULL: співробітники без жодного інциденту
SELECT se.employee_id, se.full_name, se.position
FROM security_employee se
LEFT JOIN incident i ON i.employee_id = se.employee_id
WHERE i.incident_id IS NULL;

-- 2.4 CROSS JOIN: матриця «статус × серйозність» з кількістю інцидентів
SELECT st.name AS status, sev.severity, COUNT(i.incident_id) AS incident_count
FROM incident_status st
CROSS JOIN (VALUES ('Низький'), ('Середній'), ('Високий')) AS sev(severity)
LEFT JOIN incident i ON i.status_id = st.status_id
                    AND i.severity  = sev.severity
GROUP BY st.name, sev.severity
ORDER BY st.name, sev.severity;