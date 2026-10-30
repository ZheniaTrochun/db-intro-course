SELECT * FROM patients;
 
SELECT first_name, last_name, specialization FROM doctors;
 
SELECT first_name, last_name, date_of_birth
FROM patients
WHERE date_of_birth > '2003-01-01';
 
SELECT appointment_id, appointment_date, status
FROM appointments
WHERE status = 'Заплановано'
ORDER BY appointment_date;
 
SELECT first_name
FROM patients
WHERE first_name LIKE 'Анн_';
 
SELECT * FROM appointments ORDER BY diagnosis DESC;
 
INSERT INTO patients (first_name, last_name, date_of_birth, phone, email)
VALUES ('Олена', 'Бондар', '2000-08-17', '+380975556677', 'olena.bondar@gmail.com');
 
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_end, diagnosis, status)
VALUES ((SELECT patient_id FROM patients WHERE email = 'olena.bondar@gmail.com'),
    (SELECT doctor_id  FROM doctors  WHERE phone = '+380971112233'),
    '2026-12-15 10:00:00', '2026-12-15 11:00:00', NULL, 'Заплановано');
 
SELECT * FROM appointments;
 
INSERT INTO treatments (appointment_id, type, details, status)
VALUES (49, 'ЕКГ', 'Електрокардіограма в стані спокою', 'Заплановано');
 
SELECT * FROM patients;
SELECT * FROM appointments;
SELECT * FROM treatments;
 
SELECT * FROM patients WHERE email = 'olena.bondar@gmail.com';
 
UPDATE patients
SET phone = '+380975550000'
WHERE email = 'olena.bondar@gmail.com';
 
SELECT * FROM patients WHERE email = 'olena.bondar@gmail.com';
 
SELECT * FROM appointments
WHERE appointment_date = '2026-12-15 10:00:00';
 
UPDATE appointments
SET status = 'Завершено',
    diagnosis = 'Здорова, відхилень немає'
WHERE appointment_date = '2026-12-15 10:00:00'
  AND patient_id = (SELECT patient_id FROM patients WHERE email = 'olena.bondar@gmail.com');
 
SELECT * FROM appointments WHERE diagnosis = 'Здорова, відхилень немає';
 
SELECT * FROM treatments WHERE type = 'ЕКГ';
 
UPDATE treatments
SET status = 'Завершено'
WHERE type = 'ЕКГ';
 
SELECT * FROM treatments WHERE type = 'ЕКГ';

SELECT * FROM treatments WHERE type = 'ЕКГ';
 
DELETE FROM treatments
WHERE type = 'ЕКГ';
 
SELECT * FROM treatments;
 
SELECT * FROM appointments
WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'olena.bondar@gmail.com');
 
DELETE FROM appointments
WHERE patient_id = (SELECT patient_id FROM patients WHERE email = 'olena.bondar@gmail.com');
 
DELETE FROM patients
WHERE email = 'olena.bondar@gmail.com';
 
SELECT * FROM patients WHERE email = 'olena.bondar@gmail.com';