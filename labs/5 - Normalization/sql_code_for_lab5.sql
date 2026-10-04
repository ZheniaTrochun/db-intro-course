-- 1. Створення нормалізованого довідника матеріалів і послуг Consumable
CREATE TABLE Consumable (
    consumable_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    default_price DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (default_price >= 0.00),
    default_cost DECIMAL(10,2) NOT NULL CHECK (default_cost >= 0.00)
);

-- 2. Створення нормалізованої асоціативної таблиці використання розхідників
CREATE TABLE Session_Consumable (
    session_consumable_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES Session(session_id) ON DELETE CASCADE,
    consumable_id UUID NOT NULL REFERENCES Consumable(consumable_id) ON DELETE RESTRICT,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    actual_price DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (actual_price >= 0.00),
    actual_cost DECIMAL(10,2) NOT NULL CHECK (actual_cost >= 0.00)
);

-- 3. Міграція даних із минулої таблиці
INSERT INTO Consumable (name, default_price, default_cost)
SELECT DISTINCT name, price, cost
FROM Additional_Service;

-- 4. Міграція зв'язків використання розхідників
INSERT INTO Session_Consumable (session_id, consumable_id, quantity, actual_price, actual_cost)
SELECT 
    a.session_id, 
    c.consumable_id, 
    a.quantity, 
    a.price, 
    a.cost
FROM Additional_Service a
JOIN Consumable c ON a.name = c.name;

-- 5. Видалення надлишків денормалізованої таблиці
DROP TABLE Additional_Service CASCADE;

-- 6. Усунення транзитивної залежності в таблиці Payment (видалення client_id)
ALTER TABLE Payment DROP COLUMN client_id;