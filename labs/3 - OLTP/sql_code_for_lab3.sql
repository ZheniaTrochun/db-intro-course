-- 1. SELECT. отримання розкладу запланованих сеансів
SELECT session_id, client_id, service_id, session_date, start_time, end_time, status
FROM Session
WHERE status = 'Scheduled'
ORDER BY session_date, start_time;

-- 2. SELECT. пошук клієнтів з алергією
SELECT full_name, phone_number, medical_notes
FROM Client
WHERE medical_notes ILIKE '%алергія%';

-- 3. INSERT. реєстрація нового клієнта в CRM
INSERT INTO Client (telegram_username, full_name, phone_number, birth_date, medical_notes)
VALUES ('y_shevchenko', 'Шевченко Юрій Олексійович', '+380631122334', '1998-05-14', 'Проблеми з шийним відділом');

-- 4. INSERT. призначення сеансу новому клієнту
INSERT INTO Session (client_id, service_id, session_date, start_time, end_time, status)
VALUES (
    (SELECT client_id FROM Client WHERE phone_number = '+380631122334'),
    (SELECT service_id FROM Service WHERE name = 'Шийно-комірцева зона'),
    '2026-09-25', '11:00:00', '11:30:00', 'Scheduled'
);

-- 5. UPDATE. перенесення часу проведення сеансу
UPDATE Session
SET start_time = '11:30:00', end_time = '12:00:00'
WHERE client_id = (SELECT client_id FROM Client WHERE phone_number = '+380631122334')
  AND session_date = '2026-09-25';

-- 6. UPDATE. завершення сеансу та зміна його статусу на 'Completed'
UPDATE Session
SET status = 'Completed'
WHERE client_id = (SELECT client_id FROM Client WHERE phone_number = '+380631122334')
  AND session_date = '2026-09-25';

-- 7. INSERT. додавання тестового розхідного матеріалу
INSERT INTO Additional_Service (session_id, name, quantity, price, cost)
VALUES (
    (SELECT s.session_id FROM Session s JOIN Client c ON s.client_id = c.client_id WHERE c.phone_number = '+380631122334' AND s.session_date = '2026-09-25'),
    'Тестовий пробник олії', 1, 0.00, 15.00
);

-- 8. DELETE. безпечне видалення внесеного тестового розхідника
DELETE FROM Additional_Service
WHERE name = 'Тестовий пробник олії'
  AND session_id = (SELECT s.session_id FROM Session s JOIN Client c ON s.client_id = c.client_id WHERE c.phone_number = '+380631122334' AND s.session_date = '2026-09-25');
