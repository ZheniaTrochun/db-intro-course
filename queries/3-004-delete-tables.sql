-- 4.1 Безпечна перевірка в транзакції: DELETE, перевірка, ROLLBACK
BEGIN;

DELETE FROM incident_participant
WHERE incident_id = (SELECT incident_id FROM incident
                     WHERE description LIKE 'Тестовий інцидент (лаб. 3)%');

SELECT COUNT(*) AS participants_left_in_transaction
FROM incident_participant
WHERE incident_id = (SELECT incident_id FROM incident
                     WHERE description LIKE 'Тестовий інцидент (лаб. 3)%');   -- очікується 0

ROLLBACK;   -- скасовуємо, рядок повертається

SELECT COUNT(*) AS participants_after_rollback
FROM incident_participant
WHERE incident_id = (SELECT incident_id FROM incident
                     WHERE description LIKE 'Тестовий інцидент (лаб. 3)%');   -- очікується 1

-- 4.2 Справжнє видалення тестових даних (з COMMIT)
BEGIN;

-- 4.2.1 учасник
DELETE FROM incident_participant
WHERE incident_id = (SELECT incident_id FROM incident
                     WHERE description LIKE 'Тестовий інцидент (лаб. 3)%');

-- 4.2.2 інцидент
DELETE FROM incident
WHERE description LIKE 'Тестовий інцидент (лаб. 3)%';

-- 4.2.3 візит тестового студента
DELETE FROM visit
WHERE student_id = (SELECT student_id FROM student
                    WHERE full_name = 'Тестовий Студент Іванович');

-- 4.2.4 тестовий студент
DELETE FROM student
WHERE full_name = 'Тестовий Студент Іванович';

COMMIT;

-- Перевірка: тестових рядків більше немає
SELECT COUNT(*) AS test_students FROM student
WHERE full_name = 'Тестовий Студент Іванович';                                 -- очікується 0
SELECT COUNT(*) AS test_incidents FROM incident
WHERE description LIKE 'Тестовий інцидент (лаб. 3)%';                          -- очікується 0
