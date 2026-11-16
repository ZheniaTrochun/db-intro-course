-- Тестові дані для лабораторної 6 (після всіх міграцій)
-- Запускати в pgAdmin Query Tool без BEGIN/COMMIT

INSERT INTO faculty (name) VALUES
    ('ФІОТ'),
    ('ФПМ');

INSERT INTO student_group (faculty_id, name) VALUES
    (1, 'ІО-31'),
    (1, 'ІО-32'),
    (2, 'КП-31');

INSERT INTO student (group_id, full_name) VALUES
    (1, 'Коваленко Олена Петрівна'),
    (1, 'Шевченко Андрій Іванович'),
    (2, 'Бондаренко Марія Сергіївна'),
    (3, 'Мельник Дмитро Олегович');

INSERT INTO security_employee (full_name, position, phone, email) VALUES
    ('Литвиненко Сергій Романович', 'Черговий охоронець', '+380501112233', 'lytvynenko@example.com'),
    ('Ткаченко Ірина Василівна', 'Старший охоронець', '+380672223344', 'tkachenko@example.com');

INSERT INTO incident_type (name) VALUES
    ('Порушення правил поведінки'),
    ('Пошкодження майна'),
    ('Конфлікт');

INSERT INTO incident_status (name) VALUES
    ('Відкрито'),
    ('В обробці'),
    ('Закрито');

INSERT INTO participant_role (name) VALUES
    ('Порушник'),
    ('Свідок'),
    ('Потерпілий');

INSERT INTO visit (student_id, visit_type, started_at, ended_at) VALUES
    (1, 'Відпочинок', '2026-11-10 10:00', '2026-11-10 12:30'),
    (2, 'Навчання',   '2026-11-10 11:00', '2026-11-10 13:00'),
    (3, 'Відпочинок', '2026-11-11 15:00', NULL),
    (4, 'Спорт',      '2026-11-12 09:00', '2026-11-12 11:00');

INSERT INTO incident (visit_id, type_id, employee_id, status_id, occurred_at, severity, resolved_at) VALUES
    (1, 1, 1, 1, '2026-11-10 11:15', 'Низький',  NULL),
    (2, 3, 2, 2, '2026-11-10 12:00', 'Середній', NULL),
    (4, 2, 1, 3, '2026-11-12 10:20', 'Високий',  '2026-11-12 14:00');

INSERT INTO incident_participant (incident_id, visit_id, role_id) VALUES
    (1, 1, 1),
    (2, 2, 1),
    (2, 1, 2),
    (3, 4, 1);