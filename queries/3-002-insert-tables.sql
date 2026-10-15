-- 2.1 Новий студент
INSERT INTO student (group_id, faculty_id, full_name)
VALUES (52, 1, 'Тестовий Студент Іванович');

-- Перевірка
SELECT * FROM student WHERE full_name = 'Тестовий Студент Іванович';

-- 2.2 Новий візит цього студента (category за замовчуванням 'Відпочинок')
INSERT INTO visit (student_id, started_at, ended_at)
VALUES (
    (SELECT student_id FROM student WHERE full_name = 'Тестовий Студент Іванович'),
    '2026-10-14 14:00:00',
    '2026-10-14 16:00:00'
);

-- Перевірка
SELECT v.visit_id, v.category, v.started_at, v.ended_at
FROM visit v
JOIN student s ON s.student_id = v.student_id
WHERE s.full_name = 'Тестовий Студент Іванович';

-- 2.3 Новий інцидент (status_id за замовчуванням = 1 'Новий')
INSERT INTO incident (visit_id, type_id, employee_id, description, occurred_at, severity)
VALUES (
    (SELECT v.visit_id
     FROM visit v
     JOIN student s ON s.student_id = v.student_id
     WHERE s.full_name = 'Тестовий Студент Іванович'),
    (SELECT type_id FROM incident_type WHERE name = 'Засмічення території'),
    1,
    'Тестовий інцидент (лаб. 3)',
    '2026-10-14 15:00:00',
    'Низький'
);

-- Перевірка
SELECT incident_id, status_id, description, severity
FROM incident
WHERE description = 'Тестовий інцидент (лаб. 3)';

-- 2.4 Учасник цього інциденту (роль «Свідок»)
INSERT INTO incident_participant (incident_id, visit_id, role_id)
VALUES (
    (SELECT incident_id FROM incident WHERE description = 'Тестовий інцидент (лаб. 3)'),
    (SELECT v.visit_id
     FROM visit v
     JOIN student s ON s.student_id = v.student_id
     WHERE s.full_name = 'Тестовий Студент Іванович'),
    (SELECT role_id FROM participant_role WHERE name = 'Свідок')
);

-- Перевірка
SELECT * FROM incident_participant
WHERE incident_id = (SELECT incident_id FROM incident
                     WHERE description = 'Тестовий інцидент (лаб. 3)');