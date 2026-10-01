-- розширення для автоматичної генерації UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. створення ENUM для статусів сеансу
CREATE TYPE session_status AS ENUM ('Scheduled', 'Completed', 'Cancelled');

-- 2. таблиця Клієнтів (Client)
CREATE TABLE Client (
    client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_username VARCHAR(32) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    birth_date DATE,
    medical_notes TEXT,
    CONSTRAINT chk_client_contact CHECK (phone_number IS NOT NULL OR telegram_username IS NOT NULL)
);

-- 3. таблиця Послуг (Service)
CREATE TABLE Service (
    service_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    duration_mins INT NOT NULL CHECK (duration_mins > 0),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0.00)
);

-- 4. таблиця Сеансів (Session)
CREATE TABLE Session (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES Client(client_id) ON DELETE RESTRICT,
    service_id UUID NOT NULL REFERENCES Service(service_id) ON DELETE RESTRICT,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status session_status NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT chk_session_time CHECK (end_time > start_time)
);

-- 5. таблиця додаткових послуг та витрат (Additional_Service)
CREATE TABLE Additional_Service (
    additional_service_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES Session(session_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (price >= 0.00),
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0.00)
);

-- 6. таблиця оплат (Payment)
CREATE TABLE Payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL UNIQUE REFERENCES Session(session_id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES Client(client_id) ON DELETE RESTRICT,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (discount >= 0.00),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0.00),
    net_profit DECIMAL(10,2) NOT NULL,
    payment_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_payment_discount CHECK (discount <= total_amount),
    CONSTRAINT chk_payment_profit CHECK (net_profit <= total_amount)
);

-- заповнення тестовими даними (DML)

-- додавання клієнтів
INSERT INTO Client (client_id, telegram_username, full_name, phone_number, birth_date, medical_notes) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'v_ivanov', 'Іванов Василь Петрович', '+380501112233', '1995-04-12', 'Грижа поперекового відділу'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'olena_k', 'Ковальчук Олена Ігорівна', '+380672223344', '1990-08-23', 'Алергія на цитрусові олії'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'dmytro_m', 'Мельник Дмитро Сергійович', '+380933334455', '2001-11-05', NULL),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', NULL, 'Бондаренко Анна Вікторівна', '+380994445566', '1988-02-17', 'Гіпертонія 1 ступеня');

-- додавання послуг
INSERT INTO Service (service_id, name, duration_mins, base_price) VALUES
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b21', 'Класичний масаж спини', 45, 600.00),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Спортивний масаж', 60, 800.00),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b23', 'Лімфодренажний масаж', 90, 1100.00),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b24', 'Шийно-комірцева зона', 30, 450.00);

-- додавання сеансів
INSERT INTO Session (session_id, client_id, service_id, session_date, start_time, end_time, status) VALUES
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c31', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', '2026-09-20', '10:00:00', '11:00:00', 'Completed'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c32', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b21', '2026-09-20', '12:00:00', '12:45:00', 'Completed'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b23', '2026-09-21', '14:00:00', '15:30:00', 'Completed'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c34', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b24', '2026-09-22', '16:00:00', '16:30:00', 'Scheduled');

-- додавання додаткових послуг / витратних матеріалів
INSERT INTO Additional_Service (additional_service_id, session_id, name, quantity, price, cost) VALUES
('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d41', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c31', 'Кінезіотейпування плеча', 1, 200.00, 50.00),
('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d42', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c31', 'Одноразовий набір (простирадло, капці)', 1, 0.00, 40.00),
('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380d44', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'Преміальна олія для лімфодренажу', 1, 100.00, 60.00);

-- додавання оплат за завершені сеанси

INSERT INTO Payment (payment_id, session_id, client_id, discount, total_amount, net_profit, payment_time) VALUES
-- сеанс 1: базова 800 + доп 200 = 1000 total. витрати 50 + 40 = 90. чистий: 910.
('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e51', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c31', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 0.00, 1000.00, 910.00, '2026-09-20 11:05:00'),
-- сеанс 2: базова 600 - знижка 50 = 550 total. витрати 40. чистий: 510.
('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e52', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c32', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 50.00, 550.00, 510.00, '2026-09-20 12:50:00'),
-- сеанс 3: базова 1100 + доп 100 = 1200 total. витрати 60. чистий: 1140.
('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380e53', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 0.00, 1200.00, 1140.00, '2026-09-21 15:35:00');

