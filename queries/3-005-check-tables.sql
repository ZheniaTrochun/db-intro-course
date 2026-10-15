SELECT 'student' AS t, COUNT(*) FROM student UNION ALL
SELECT 'security_employee', COUNT(*) FROM security_employee UNION ALL
SELECT 'incident_type', COUNT(*) FROM incident_type UNION ALL
SELECT 'incident_status', COUNT(*) FROM incident_status UNION ALL
SELECT 'participant_role', COUNT(*) FROM participant_role UNION ALL
SELECT 'visit', COUNT(*) FROM visit UNION ALL
SELECT 'incident', COUNT(*) FROM incident UNION ALL
SELECT 'incident_participant', COUNT(*) FROM incident_participant;