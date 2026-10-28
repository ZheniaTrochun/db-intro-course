-- Схема бази даних OpenCRM (чорновий варіант)
-- Виконали студенти групи ІМ-54: Рубан Олексій, Гладченко Віталій, Симоненко Поліна, Грищенко Ілля

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
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE users IS 'Співробітники та менеджери системи OpenCRM';
COMMENT ON COLUMN users.email IS 'Унікальна корпоративна електронна адреса';

-- 3. Таблиця контрагентів (клієнтська база)
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE clients IS 'Клієнти та компанії-контрагенти';

-- 4. Таблиця угод (воронка продажів)
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
COMMENT ON COLUMN deals.total_amount IS 'Загальна сума угоди (перераховується за позиціями)';

-- 5. Довідник товарів та послуг
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    base_price DECIMAL(12, 2) NOT NULL CHECK (base_price >= 0)
);

COMMENT ON TABLE products IS 'Каталог товарів та послуг';

-- 6. Позиції товарів в угоді (асоціативна таблиця M:N)
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
