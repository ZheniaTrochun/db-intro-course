SELECT COUNT(*) AS total_doctors FROM doctors;

SELECT COUNT(*) FROM appointments
WHERE status = 'Заплановано';

SELECT MIN(date_of_birth), MAX(date_of_birth)
FROM patients;

SELECT AVG(appointment_end - appointment_date)
FROM appointments;

SELECT status, COUNT(*) AS num 
FROM appointments
GROUP BY status;

SELECT doctor_id, COUNT(*) AS num
FROM appointments
GROUP BY doctor_id;

SELECT doctor_id, COUNT(*) AS num
FROM appointments
GROUP BY doctor_id
HAVING COUNT(*) > 1;

SELECT type, COUNT(*) AS num
FROM treatments
GROUP BY type;

SELECT p.last_name, a.appointment_date
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id;

SELECT d.last_name, p.last_name, a.appointment_date
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id 
LEFT JOIN doctors d ON d.doctor_id = a.doctor_id;

SELECT d.doctor_id, a.appointment_date
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id;

SELECT d.doctor_id, a.appointment_date
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
WHERE appointment_date IS NULL;

SELECT d.last_name, dd.name
FROM doctors d
JOIN doctor_departments dp ON d.doctor_id = dp.doctor_id
JOIN departments dd ON dd.department_id = dp.department_id;

SELECT p.last_name, t.type
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN treatments t ON a.appointment_id = t.appoi

SELECT d.doctor_id, dp.department_id
FROM doctors d
CROSS JOIN departments dp;

SELECT d.last_name, COUNT(a.appointment_id)
FROM doctors d
INNER JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.last_name;

SELECT p.patient_id, COUNT(a.appointment_id)
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id;

SELECT p.patient_id, COUNT(t.treatment_id)
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id
INNER JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY p.patient_id;

SELECT COUNT(d.doctor_id), dp.department_id
FROM doctors d
INNER JOIN doctor_departments dp ON d.doctor_id = dp.doctor_id
GROUP BY dp.department_id
HAVING COUNT(*) > 1;