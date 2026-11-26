-- Додаткові та оновлені OLTP-запити до Лабораторної роботи №3 (OpenCRM)
-- Виконали студенти групи ІМ-54: Рубан Олексій, Гладченко Віталій, Симоненко Поліна, Грищенко Ілля


-- =====================================================================
-- ЧАСТИНА 1. Рубан Олексій Андрійович (група ІМ-54)
-- =====================================================================

-- 1 Сценарій: Додавання нового користувача та перевірка його наявності.
SELECT * FROM users;

INSERT INTO users (full_name, email, password_hash, role)
VALUES
(
    'John Pork',
    'johnpork@example.com',
    '$2b$12$...',
    'manager'
);

SELECT * FROM users
WHERE full_name = 'John Pork';

UPDATE users
SET email = 'johnpork@gmail.com'
WHERE full_name = 'John Pork'
RETURNING id, full_name, email;

DELETE FROM users
WHERE full_name = 'John Pork'
RETURNING id, full_name;

SELECT * FROM users
WHERE full_name = 'John Pork';

SELECT * FROM users;

-- 2 Сценарій: Перевірка та додавання нових позицій в угоду (чек).
SELECT * FROM deals;

SELECT * FROM deal_products
WHERE deal_id = 3;

SELECT * FROM products;

INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES
(
    3, 2, 1, 13500.00
)
RETURNING deal_id, product_id, quantity, actual_price;

INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES
(
    3, 5, 1, 9999.00
)
RETURNING deal_id, product_id, quantity, actual_price;

SELECT * FROM deal_products
WHERE deal_id = 3;

UPDATE deal_products
SET quantity = 2, actual_price = 10000.00
WHERE deal_id = 3 AND product_id = 5
RETURNING deal_id, product_id, quantity, actual_price;

SELECT * FROM deal_products
WHERE deal_id = 3;

DELETE FROM deal_products
WHERE deal_id = 3 AND product_id IN (2, 5);

SELECT * FROM deal_products
WHERE deal_id = 3;


-- =====================================================================
-- ЧАСТИНА 2. Грищенко Ілля Євгенович (група ІМ-54)
-- =====================================================================

-- Сценарій 1: Робота з клієнтами (clients)
-- Повний цикл операцій (INSERT -> UPDATE -> SELECT -> DELETE) для нового запису клієнта:

INSERT INTO clients (company_name, contact_person, phone, email)
VALUES ('ТОВ «Київ Логістик»', 'Ткаченко Олег', '+380671234567', 'oleg.tkachenko@gmail.com');

UPDATE clients
SET phone = '+380677654321'
WHERE email = 'oleg.tkachenko@gmail.com';

SELECT * FROM clients
WHERE email = 'oleg.tkachenko@gmail.com';

DELETE FROM clients
WHERE email = 'oleg.tkachenko@gmail.com';

-- Сценарій 2: Робота з послугами (products)
-- Повний цикл операцій (INSERT -> UPDATE -> SELECT -> DELETE) для нової позиції в каталозі:

INSERT INTO products (name, base_price)
VALUES ('Технічна підтримка', 3000.00);

UPDATE products
SET base_price = 3500.00
WHERE name = 'Технічна підтримка';

SELECT * FROM products
WHERE name = 'Технічна підтримка';

DELETE FROM products
WHERE name = 'Технічна підтримка';


-- =====================================================================
-- ЧАСТИНА 3. Симоненко Поліна (група ІМ-54)
-- =====================================================================

-- Сценарій 1: Додавання нового клієнта, оновлення контакту та видалення (clients)
-- 1. Перевіряємо поточний список клієнтів (SELECT)
SELECT * FROM clients;

-- 2. Додаємо нового тестового клієнта (INSERT)
-- Використовуємо RETURNING, щоб одразу побачити згенерований id та додані дані.
INSERT INTO clients (company_name, contact_person, phone, email)
VALUES (
    'ТОВ «Тест Клієнт»',
    'Іваненко Олена',
    '+380501112233',
    'test.client@example.com'
)
RETURNING id, company_name, contact_person, phone, email;

-- 3. Перевіряємо, що клієнт з'явився у таблиці (SELECT)
SELECT * FROM clients
WHERE company_name = 'ТОВ «Тест Клієнт»';

-- 4. Оновлюємо телефон та контактну особу клієнта (UPDATE)
-- Обов'язково вказуємо умову WHERE, щоб змінити лише потрібного клієнта, а не всю таблицю.
UPDATE clients
SET
    phone = '+380674445566',
    contact_person = 'Іваненко Олена (Менеджер)'
WHERE company_name = 'ТОВ «Тест Клієнт»'
RETURNING id, company_name, contact_person, phone;

-- 5. Перевіряємо зміни після оновлення (SELECT)
SELECT * FROM clients
WHERE company_name = 'ТОВ «Тест Клієнт»';

-- 6. Видаляємо тестового клієнта (DELETE)
DELETE FROM clients
WHERE company_name = 'ТОВ «Тест Клієнт»'
RETURNING id, company_name;

-- 7. Фінальна перевірка після видалення (SELECT)
-- Переконуємося, що тестовий запис видалено, а основна таблиця залишилася чистою.
SELECT * FROM clients
WHERE company_name = 'ТОВ «Тест Клієнт»';

SELECT * FROM clients;

-- Сценарій 2: Робота з позиціями в угоді №3 (deal_products)
-- 1. Перевіряємо угоду №3, її поточний склад та каталог товарів (SELECT)
SELECT * FROM deals WHERE id = 3;

SELECT * FROM deal_products
WHERE deal_id = 3;

SELECT * FROM products;

-- 2. Додаємо два нові товари до угоди №3 (INSERT)
-- Використано product_id = 4 та 2 (оскільки product_id = 1 і 3 уже закріплені за угодою №3 у початкових даних, а пара (deal_id, product_id) унікальна)
INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES (3, 4, 1, 35000.00)
RETURNING deal_id, product_id, quantity, actual_price;

INSERT INTO deal_products (deal_id, product_id, quantity, actual_price)
VALUES (3, 2, 1, 12000.00)
RETURNING deal_id, product_id, quantity, actual_price;

-- 3. Перевіряємо склад угоди №3 після додавання товарів (SELECT)
SELECT * FROM deal_products
WHERE deal_id = 3;

-- 4. Оновлюємо кількість та ціну другого товару в угоді №3 (UPDATE)
UPDATE deal_products
SET
    quantity = 2,
    actual_price = 11500.00
WHERE deal_id = 3 AND product_id = 2
RETURNING deal_id, product_id, quantity, actual_price;

-- 5. Перевіряємо склад угоди №3 після оновлення (SELECT)
SELECT * FROM deal_products
WHERE deal_id = 3;

-- 6. Видаляємо додані тестові позиції з угоди №3 (DELETE)
DELETE FROM deal_products
WHERE deal_id = 3 AND product_id IN (4, 2)
RETURNING deal_id, product_id;

-- 7. Фінальна перевірка складу угоди №3 (SELECT)
SELECT * FROM deal_products
WHERE deal_id = 3;
