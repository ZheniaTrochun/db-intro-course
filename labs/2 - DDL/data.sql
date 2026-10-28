-- Тестові дані для бази даних OpenCRM
-- Виконали студенти групи ІМ-54: Рубан Олексій, Гладченко Віталій, Симоненко Поліна, Грищенко Ілля

-- 1. Співробітники компанії
INSERT INTO users (full_name, email, password_hash, role, created_at) VALUES
    ('Рубан Олексій', 'oleksii.ruban@opencrm.ua', '$2b$12$e8YQ5FvX1xK8dJ.0qP9h6u3fE7aK5bL8cM9n0oP1qR2sT3uV4wX5y', 'admin', '2026-09-01 09:00:00+03'),
    ('Віталій Гладченко', 'vitalii.hladchenko@opencrm.ua', '$2b$12$K1rT5mY8zP3wQ6vX9sA2b.4cD7eF0gH3jK6mN9pQ2sU5wX8yA1b2c', 'manager', '2026-09-05 10:15:00+03'),
    ('Симоненко Поліна', 'polina.symonenko@opencrm.ua', '$2b$12$L2sU6nZ9aQ4xR7wY0tB3c.5dE8fG1hI4kL7nO0qR3tV6xY9zB2c3d', 'manager', '2026-09-10 11:30:00+03'),
    ('Грищенко Ілля', 'illia.hryshchenko@opencrm.ua', '$2b$12$M3tV7oA0bR5yS8xZ1uC4d.6eF9gH2iJ5lM8oP1rS4uW7yZ0aC3d4e', 'manager', '2026-09-12 14:00:00+03'),
    ('Андрій Ковальчук', 'andrii.kovalchuk@opencrm.ua', '$2b$12$N4uW8pB1cS6zT9yA2vD5e.7fG0hI3jK6mN9pQ2sT5vX8zA1bD4e5f', 'manager', '2026-09-15 09:45:00+03');

-- 2. Клієнти (контрагенти)
INSERT INTO clients (company_name, contact_person, phone, email, created_at) VALUES
    ('ТОВ «Нова Пошта Технолоджі»', 'Мельник Тарас Григорович', '+380501112233', 'tech@novaposhta.ua', '2026-09-16 10:00:00+03'),
    ('ПрАТ «Київстар Дігітал»', 'Шевченко Олена Вікторівна', '+380672223344', 'digital@kyivstar.net', '2026-09-18 11:20:00+03'),
    ('ТОВ «Розетка Маркетплейс»', 'Коваленко Богдан Ігорович', '+380633334455', 'b2b@rozetka.ua', '2026-09-20 15:40:00+03'),
    ('ПП «Агро-Експорт Груп»', 'Бондаренко Ірина Сергіївна', '+380444445566', 'sales@agroexport.com.ua', '2026-09-25 09:10:00+03'),
    ('ТОВ «Фармак Інновації»', 'Кравченко Максим Юрійович', '+380505556677', 'partners@farmak.ua', '2026-10-01 13:00:00+03');

-- 3. Каталог товарів та сервісів
INSERT INTO products (name, base_price) VALUES
    ('Впровадження CRM OpenCRM (базовий пакет)', 25000.00),
    ('Інтеграція з IP-телефонією та месенджерами', 12000.00),
    ('Річна підписка на хмарну інфраструктуру', 18000.00),
    ('Розробка індивідуального модуля аналітики', 35000.00),
    ('Пакет технічної підтримки 24/7 (1 місяць)', 8000.00),
    ('Корпоративний тренінг для персоналу', 10000.00);

-- 4. Угоди у воронці продажів
INSERT INTO deals (client_id, manager_id, status, total_amount, created_at, updated_at) VALUES
    (1, 1, 'won', 55000.00, '2026-09-18 12:00:00+03', '2026-10-05 16:30:00+03'),
    (2, 2, 'contract', 71000.00, '2026-09-22 14:15:00+03', '2026-10-12 11:00:00+03'),
    (3, 3, 'negotiation', 43000.00, '2026-09-28 09:30:00+03', '2026-10-15 17:20:00+03'),
    (4, 4, 'new', 35000.00, '2026-10-05 15:00:00+03', '2026-10-05 15:00:00+03'),
    (5, 2, 'lost', 25000.00, '2026-10-08 10:45:00+03', '2026-10-20 18:00:00+03');

-- 5. Товари в угодах (позиції M:N)
INSERT INTO deal_products (deal_id, product_id, quantity, actual_price) VALUES
    (1, 1, 1, 25000.00),
    (1, 2, 1, 12000.00),
    (1, 3, 1, 18000.00),
    (2, 1, 1, 24000.00),
    (2, 4, 1, 35000.00),
    (2, 2, 1, 12000.00),
    (3, 1, 1, 25000.00),
    (3, 3, 1, 18000.00),
    (4, 1, 1, 25000.00),
    (4, 6, 1, 10000.00),
    (5, 1, 1, 25000.00);

-- 6. Завдання співробітників
INSERT INTO tasks (deal_id, assigned_to, task_type, due_date, status) VALUES
    (3, 3, 'call', CURRENT_TIMESTAMP + INTERVAL '1 day', 'pending'),
    (2, 2, 'meeting', CURRENT_TIMESTAMP + INTERVAL '2 days', 'pending'),
    (1, 1, 'email', CURRENT_TIMESTAMP - INTERVAL '3 days', 'completed'),
    (4, 4, 'call', CURRENT_TIMESTAMP + INTERVAL '4 hours', 'pending'),
    (5, 2, 'email', CURRENT_TIMESTAMP - INTERVAL '5 days', 'completed'),
    (NULL, 1, 'meeting', CURRENT_TIMESTAMP + INTERVAL '3 days', 'pending');

-- 7. Журнал аудиту
INSERT INTO audit_logs (entity_type, entity_id, changed_by, action, old_data, new_data, created_at) VALUES
    ('deal', 1, 1, 'CREATE', NULL, '{"client_id": 1, "manager_id": 1, "status": "new", "total_amount": 55000.00}'::jsonb, '2026-09-18 12:00:00+03'),
    ('deal', 1, 1, 'UPDATE_STATUS', '{"status": "contract"}'::jsonb, '{"status": "won"}'::jsonb, '2026-10-05 16:30:00+03'),
    ('task', 3, 1, 'UPDATE_STATUS', '{"status": "pending"}'::jsonb, '{"status": "completed"}'::jsonb, '2026-10-06 11:00:00+03'),
    ('client', 2, 2, 'UPDATE_DATA', '{"contact_person": "Шевченко Олена"}'::jsonb, '{"contact_person": "Шевченко Олена Вікторівна"}'::jsonb, '2026-10-08 14:10:00+03'),
    ('deal', 5, 2, 'UPDATE_STATUS', '{"status": "negotiation"}'::jsonb, '{"status": "lost", "reason": "перевищення бюджету клієнта"}'::jsonb, '2026-10-20 18:00:00+03');
