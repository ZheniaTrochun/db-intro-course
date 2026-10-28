-- Повний скрипт розгортання схеми та тестових даних OpenCRM
-- Виконали студенти групи ІМ-54: Рубан Олексій, Гладченко Віталій, Симоненко Поліна, Грищенко Ілля


-- Очищення існуючих об'єктів для ідемпотентності
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS deal_products CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS deals CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP TYPE IF EXISTS task_status CASCADE;
DROP TYPE IF EXISTS task_type CASCADE;
DROP TYPE IF EXISTS deal_status CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;

-- 1. Створення користувацьких перелічуваних типів (ENUM)
CREATE TYPE user_role AS ENUM ('admin', 'manager');
CREATE TYPE deal_status AS ENUM ('new', 'negotiation', 'contract', 'won', 'lost');
CREATE TYPE task_type AS ENUM ('call', 'meeting', 'email');
CREATE TYPE task_status AS ENUM ('pending', 'completed');

-- 2. Таблиця співробітників (користувачів системи)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'manager',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_users_email CHECK (email LIKE '%@%.%')
);

COMMENT ON TABLE users IS 'Співробітники та менеджери системи OpenCRM';
COMMENT ON COLUMN users.full_name IS 'Повне ім''я співробітника';
COMMENT ON COLUMN users.email IS 'Унікальна корпоративна електронна адреса';
COMMENT ON COLUMN users.role IS 'Роль у системі: admin або manager';

-- 3. Таблиця контрагентів (клієнтська база)
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_clients_email CHECK (email LIKE '%@%.%')
);

COMMENT ON TABLE clients IS 'Клієнти та компанії-контрагенти';
COMMENT ON COLUMN clients.company_name IS 'Офіційна назва компанії клієнта';
COMMENT ON COLUMN clients.contact_person IS 'ПІБ контактної особи з боку клієнта';

-- 4. Довідник товарів та послуг
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    base_price DECIMAL(12, 2) NOT NULL CHECK (base_price >= 0)
);

COMMENT ON TABLE products IS 'Каталог товарів та сервісних послуг';
COMMENT ON COLUMN products.name IS 'Назва товару або послуги';
COMMENT ON COLUMN products.base_price IS 'Базова прейскурантна вартість';

-- 5. Таблиця угод (воронка продажів)
CREATE TABLE deals (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    manager_id INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status deal_status NOT NULL DEFAULT 'new',
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deals_client_id ON deals(client_id);
CREATE INDEX idx_deals_manager_id ON deals(manager_id);
CREATE INDEX idx_deals_status ON deals(status);

COMMENT ON TABLE deals IS 'Угоди воронки продажів';
COMMENT ON COLUMN deals.total_amount IS 'Загальна сума угоди (розраховується за позиціями)';
COMMENT ON COLUMN deals.status IS 'Поточний етап угоди у воронці продажів';

-- 6. Позиції товарів в угоді (асоціативна таблиця зв''язку M:N)
CREATE TABLE deal_products (
    id SERIAL PRIMARY KEY,
    deal_id INT NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    actual_price DECIMAL(12, 2) NOT NULL CHECK (actual_price >= 0),
    CONSTRAINT uq_deal_product UNIQUE (deal_id, product_id)
);

CREATE INDEX idx_deal_products_deal_id ON deal_products(deal_id);
CREATE INDEX idx_deal_products_product_id ON deal_products(product_id);

COMMENT ON TABLE deal_products IS 'Позиції товарів, включених до конкретної угоди';
COMMENT ON COLUMN deal_products.actual_price IS 'Фіксована ціна продажу на момент оформлення угоди';

-- 7. Завдання та активності менеджерів
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    deal_id INT REFERENCES deals(id) ON DELETE SET NULL,
    assigned_to INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    task_type task_type NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status task_status NOT NULL DEFAULT 'pending'
);

CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_deal_id ON tasks(deal_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

COMMENT ON TABLE tasks IS 'Оперативні завдання (дзвінки, зустрічі, листи) менеджерів';
COMMENT ON COLUMN tasks.deal_id IS 'Посилання на пов''язану угоду (опціонально)';

-- 8. Журнал аудиту змін
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT NOT NULL,
    changed_by INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    action VARCHAR(50) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_changed_by ON audit_logs(changed_by);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

COMMENT ON TABLE audit_logs IS 'Незмінний журнал аудиту змін сутностей системи';


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
