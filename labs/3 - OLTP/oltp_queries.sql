-- OLTP-запити для бази даних OpenCRM
-- Виконали студенти групи ІМ-54: Рубан Олексій, Гладченко Віталій, Симоненко Поліна, Грищенко Ілля

-- 1. Операції читання та вибірки даних (SELECT)

-- 1.1. Базова вибірка контактних даних клієнтів
SELECT 
    id,
    company_name,
    contact_person,
    phone,
    email
FROM clients
ORDER BY company_name ASC;

-- 1.2. Фільтрація угод за статусом у воронці та сортування за сумою
SELECT 
    id,
    client_id,
    manager_id,
    status,
    total_amount
FROM deals
WHERE status IN ('negotiation', 'contract')
ORDER BY total_amount DESC;

-- 1.3. Вибірка виграних угод з іменами менеджерів та клієнтів (INNER JOIN)
SELECT 
    d.id AS deal_id,
    c.company_name AS client_name,
    u.full_name AS manager_name,
    d.status,
    d.total_amount,
    d.updated_at AS won_date
FROM deals d
JOIN clients c ON d.client_id = c.id
JOIN users u ON d.manager_id = u.id
WHERE d.status = 'won';

-- 1.4. Деталізація складу угоди №2 (M:N) та перевірка знижок
SELECT 
    dp.deal_id,
    p.name AS product_name,
    p.base_price AS catalog_price,
    dp.actual_price AS sold_price,
    dp.quantity,
    (dp.quantity * dp.actual_price) AS line_total,
    (dp.actual_price - p.base_price) AS price_diff
FROM deal_products dp
JOIN products p ON dp.product_id = p.id
WHERE dp.deal_id = 2;

-- 1.5. Актуальні завдання менеджерів (Симоненко Поліна та Грищенко Ілля)
SELECT 
    t.id AS task_id,
    u.full_name AS assigned_manager,
    t.task_type,
    t.status AS task_status,
    t.due_date,
    t.deal_id
FROM tasks t
JOIN users u ON t.assigned_to = u.id
WHERE t.status = 'pending'
  AND u.full_name IN ('Симоненко Поліна', 'Грищенко Ілля')
ORDER BY t.due_date ASC;


-- 2. Додавання нових записів (INSERT)

-- 2.1. Реєстрація нового клієнта з поверненням згенерованого ID (RETURNING)
INSERT INTO clients (company_name, contact_person, phone, email)
VALUES (
    'ТОВ «ДТЕК Енерго Хмарні Рішення»', 
    'Коваль Дмитро Олександрович', 
    '+380509998877', 
    'cloud.solutions@dtek.com'
)
RETURNING id, company_name, created_at;

-- 2.2. Додавання нової послуги в каталог товарів
INSERT INTO products (name, base_price)
VALUES (
    'Налаштування BI-аналітики та користувацьких дашбордів', 
    16500.00
)
RETURNING id, name, base_price;

-- 2.3. Створення нової угоди для доданого клієнта (менеджер Віталій Гладченко)
INSERT INTO deals (client_id, manager_id, status, total_amount)
VALUES (
    6,
    2,
    'new',
    0.00
)
RETURNING id, client_id, manager_id, status;

-- 2.4. Додавання товарних позицій до угоди №6 (зв'язок M:N)
INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES 
    (6, 1, 1, 25000.00),
    (6, 7, 1, 16500.00);

-- Перевірка створених позицій угоди №6
SELECT * FROM deal_products WHERE deal_id = 6;


-- 3. Модифікація даних (UPDATE)

-- 3.1. Оновлення контакту клієнта за первинним ключем (з умовою WHERE)
UPDATE clients
SET 
    phone = '+380639990011',
    contact_person = 'Коваленко Богдан Ігорович (Директор з IT)'
WHERE id = 3;

-- Перевірка результату
SELECT id, company_name, contact_person, phone FROM clients WHERE id = 3;

-- 3.2. Просування угоди по воронці продажів
UPDATE deals
SET 
    status = 'negotiation',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 4 AND status = 'new';

-- Перевірка результату
SELECT id, status, updated_at FROM deals WHERE id = 4;

-- 3.3. Виконання оперативного завдання менеджером
UPDATE tasks
SET status = 'completed'
WHERE id = 1 AND status = 'pending';

-- Перевірка результату
SELECT id, task_type, status FROM tasks WHERE id = 1;

-- 3.4. Автоматичний перерахунок суми угоди №6 на основі позицій у deal_products
UPDATE deals d
SET total_amount = sub.calculated_sum,
    updated_at = CURRENT_TIMESTAMP
FROM (
    SELECT deal_id, SUM(quantity * actual_price) AS calculated_sum
    FROM deal_products
    WHERE deal_id = 6
    GROUP BY deal_id
) sub
WHERE d.id = sub.deal_id;

-- Перевірка підсумкової суми угоди №6
SELECT id, total_amount, updated_at FROM deals WHERE id = 6;


-- 4. Видалення та перевірка обмежень цілісності (DELETE)

-- 4.1. Безпечне видалення завершеного завдання за первинним ключем
DELETE FROM tasks
WHERE id = 3 AND status = 'completed';

-- 4.2. Перевірка каскадного видалення (CASCADE) та обнулення посилання (SET NULL)
-- Створюємо тимчасову тестову угоду з товарами та завданням
INSERT INTO deals (id, client_id, manager_id, status, total_amount)
VALUES (99, 1, 1, 'new', 10000.00);

INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES (99, 1, 1, 10000.00);

INSERT INTO tasks (id, deal_id, assigned_to, task_type, due_date, status)
VALUES (99, 99, 1, 'call', CURRENT_TIMESTAMP + INTERVAL '1 day', 'pending');

-- Видаляємо тестову угоду №99
DELETE FROM deals WHERE id = 99;

-- Перевірка: позиції в deal_products видалилися каскадно (CASCADE)
SELECT COUNT(*) AS cascade_check FROM deal_products WHERE deal_id = 99;

-- Перевірка: завдання збереглося, але deal_id став NULL (SET NULL)
SELECT id, deal_id, assigned_to, status FROM tasks WHERE id = 99;

-- Видаляємо тимчасове завдання
DELETE FROM tasks WHERE id = 99;

-- 4.3. Перевірка обмеження ON DELETE RESTRICT
-- Спроба видалити користувача Рубана Олексія (id = 1), за яким закріплені угоди
DO $$
BEGIN
    DELETE FROM users WHERE id = 1;
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Успішний захист цілісності: СУБД заблокувала видалення користувача id=1 через пов''язані угоди (RESTRICT).';
END $$;


-- 5. Комплексна транзакція (ACID)

-- Бізнес-кейс: Оформлення нової угоди для клієнта «Київстар»
BEGIN;

-- Крок 1: Створення угоди
INSERT INTO deals (id, client_id, manager_id, status, total_amount)
VALUES (10, 2, 3, 'negotiation', 46000.00);

-- Крок 2: Додавання товарних позицій
INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES 
    (10, 3, 2, 18000.00), -- 2 річні підписки на хмару (36 000 грн)
    (10, 6, 1, 10000.00); -- 1 корпоративний тренінг (10 000 грн)

-- Крок 3: Створення завдання менеджеру Поліні Симоненко
INSERT INTO tasks (deal_id, assigned_to, task_type, due_date, status)
VALUES (10, 3, 'email', CURRENT_TIMESTAMP + INTERVAL '2 days', 'pending');

-- Крок 4: Запис операції в журнал аудиту
INSERT INTO audit_logs (entity_type, entity_id, changed_by, action, new_data)
VALUES (
    'deal', 
    10, 
    3, 
    'CREATE', 
    '{"client_id": 2, "manager_id": 3, "status": "negotiation", "total_amount": 46000.00, "items_count": 2}'::jsonb
);

COMMIT;

-- Перевірка створеної транзакцією угоди
SELECT d.id, c.company_name, u.full_name AS manager, d.status, d.total_amount
FROM deals d
JOIN clients c ON d.client_id = c.id
JOIN users u ON d.manager_id = u.id
WHERE d.id = 10;
