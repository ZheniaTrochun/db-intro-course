-- 3.1 Підзапит у WHERE: візити, довші за середню тривалість
SELECT visit_id, student_id, category, ended_at - started_at AS duration
FROM visit
WHERE ended_at IS NOT NULL
  AND (ended_at - started_at) > (SELECT AVG(ended_at - started_at)
                                 FROM visit
                                 WHERE ended_at IS NOT NULL)
ORDER BY duration DESC;

-- 3.2 Підзапит у SELECT (корельований): студенти та кількість їхніх інцидентів
SELECT s.student_id,
       s.full_name,
       (SELECT COUNT(*)
        FROM incident i
        JOIN visit v ON v.visit_id = i.visit_id
        WHERE v.student_id = s.student_id) AS incidents_count
FROM student s
ORDER BY incidents_count DESC;

-- 3.3 Підзапит у HAVING: типи інцидентів частіші за середній
SELECT it.name, COUNT(*) AS incident_count
FROM incident i
JOIN incident_type it ON it.type_id = i.type_id
GROUP BY it.name
HAVING COUNT(*) > (SELECT AVG(cnt)
                   FROM (SELECT COUNT(*) AS cnt
                         FROM incident
                         GROUP BY type_id) AS t);

-- 3.4 Підзапит з IN: студенти, які хоч раз були «Порушником»
SELECT s.student_id, s.full_name
FROM student s
WHERE s.student_id IN (
    SELECT v.student_id
    FROM visit v
    JOIN incident_participant ip ON ip.visit_id = v.visit_id
    JOIN participant_role pr     ON pr.role_id  = ip.role_id
    WHERE pr.name = 'Порушник'
);