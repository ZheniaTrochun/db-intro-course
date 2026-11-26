-- OLAP-запити для Лабораторної роботи №4 (OpenCRM)
-- Виконали студенти групи ІМ-54: Рубан Олексій, Гладченко Віталій, Симоненко Поліна, Грищенко Ілля


-- =====================================================================
-- ЧАСТИНА 1. Рубан Олексій Андрійович (група ІМ-54)
-- =====================================================================

-- 1: Сума угод по кожному клієнту.
SELECT * FROM clients;

SELECT c.company_name, c.contact_person, COUNT(d.id) AS total_deals, SUM(d.total_amount) AS total_revenue
FROM clients c
JOIN deals d ON c.id = d.client_id
GROUP BY c.id, c.company_name, c.contact_person
ORDER BY total_revenue DESC;

-- 2: Сума угод по кожному менеджеру.
SELECT * FROM users;

SELECT u.full_name, u.role, COALESCE(COUNT(d.id), 0) AS total_deals, COALESCE(SUM(d.total_amount), 0) AS total_revenue
FROM users u
LEFT JOIN deals d ON u.id = d.manager_id
GROUP BY u.id, u.full_name, u.role
ORDER BY total_revenue DESC;

-- 3: Популярні товари та їх середня вартість.
SELECT * FROM products;
SELECT * FROM deal_products;

SELECT p.name, COUNT(dp.product_id) AS total_sales, ROUND(AVG(dp.actual_price), 2) AS average_price
FROM products p
JOIN deal_products dp ON p.id = dp.product_id
GROUP BY p.id, p.name
HAVING COUNT(dp.product_id) > 2
ORDER BY total_sales DESC;

-- 4: Кількість завдань по кожній угоді.
SELECT * FROM deals;
SELECT * FROM tasks;

SELECT d.id AS deal_id, d.status AS deal_status, d.total_amount, COUNT(t.id) AS total_tasks
FROM deals d
FULL OUTER JOIN tasks t ON d.id = t.deal_id
GROUP BY d.id, d.status, d.total_amount
ORDER BY d.id;


-- =====================================================================
-- ЧАСТИНА 2. Грищенко Ілля Євгенович (група ІМ-54)
-- =====================================================================

-- 1. Базова агрегація (COUNT, SUM, AVG, MIN, MAX)
SELECT COUNT(*) AS total_deals, SUM(total_amount) AS total_sum, AVG(total_amount) AS avg_sum, MIN(total_amount) AS min_sum, MAX(total_amount) AS max_sum
FROM deals;

-- 2. Групування та фільтрація груп (GROUP BY + HAVING)
SELECT status, COUNT(*) AS deals_count
FROM deals
GROUP BY status
HAVING COUNT(*) > 1;

-- 3. INNER JOIN та агрегація (сума угод по клієнтах)
SELECT c.company_name, SUM(d.total_amount) AS total_spent
FROM clients c
INNER JOIN deals d ON c.id = d.client_id
GROUP BY c.id, c.company_name;

-- 4. LEFT JOIN та агрегація (усі менеджери та кількість їхніх угод)
SELECT u.full_name, COUNT(d.id) AS deals_count
FROM users u
LEFT JOIN deals d ON u.id = d.manager_id
GROUP BY u.id, u.full_name;

-- 5. RIGHT JOIN (усі користувачі та їхні завдання)
SELECT u.full_name, t.task_type, t.status
FROM tasks t
RIGHT JOIN users u ON t.assigned_to = u.id;

-- 6. Підзапит у WHERE (угоди, більші за середню суму)
SELECT id, total_amount
FROM deals
WHERE total_amount > (SELECT AVG(total_amount) FROM deals);

-- 7. Підзапит у HAVING (менеджери, чия сума угод більша за середній чек)
SELECT manager_id, SUM(total_amount) AS manager_sum
FROM deals
GROUP BY manager_id
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM deals);

-- 8. Підзапит у SELECT (кількість угод для кожного клієнта)
SELECT company_name, (SELECT COUNT(*) FROM deals d WHERE d.client_id = c.id) AS deals_count
FROM clients c;


-- =====================================================================
-- ЧАСТИНА 3. Симоненко Поліна (група ІМ-54)
-- =====================================================================

-- 1. Кількість та сума угод по кожному статусу (HAVING + підзапит)
SELECT * FROM deals;

SELECT status, COUNT(id) AS total_deals, SUM(total_amount) AS total_sum
FROM deals
GROUP BY status
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM deals)
ORDER BY total_sum DESC;

-- 2. Мінімальна, максимальна та середня ціна товарів (INNER JOIN)
SELECT * FROM products;
SELECT * FROM deal_products;

SELECT p.name, MIN(dp.actual_price) AS min_price, MAX(dp.actual_price) AS max_price, ROUND(AVG(dp.actual_price), 2) AS avg_price
FROM products p
JOIN deal_products dp ON p.id = dp.product_id
GROUP BY p.id, p.name
ORDER BY avg_price DESC;

-- 3. Кількість завдань та угод по кожному менеджеру (LEFT JOIN + підзапит у SELECT)
SELECT * FROM users;
SELECT * FROM tasks;

SELECT u.full_name, COUNT(t.id) AS total_tasks, (SELECT COUNT(*) FROM deals d WHERE d.manager_id = u.id) AS total_deals
FROM users u
LEFT JOIN tasks t ON u.id = t.assigned_to
GROUP BY u.id, u.full_name
ORDER BY total_tasks DESC;

-- 4. Угоди дорожчі за середній чек та позаугодові завдання (FULL OUTER JOIN + підзапит у WHERE)
SELECT * FROM deals;
SELECT * FROM tasks;

SELECT d.id AS deal_id, d.status, d.total_amount, t.id AS task_id
FROM deals d
FULL OUTER JOIN tasks t ON d.id = t.deal_id
WHERE d.total_amount > (SELECT AVG(total_amount) FROM deals) OR t.deal_id IS NULL
ORDER BY d.id;


-- =====================================================================
-- ЧАСТИНА 4. Гладченко Віталій Васильович (група ІМ-54)
-- =====================================================================

-- 1. Статистика по статусах угод (deals — COUNT, SUM, AVG, GROUP BY)
SELECT
    status,
    COUNT(*) AS deals_count,
    COALESCE(SUM(total_amount), 0) AS total_sum,
    ROUND(COALESCE(AVG(total_amount), 0), 2) AS avg_amount
FROM deals
GROUP BY status
ORDER BY total_sum DESC;

-- 2. Продажі по кожному менеджеру (users + deals — LEFT JOIN, GROUP BY)
SELECT
    u.full_name,
    COUNT(d.id) AS deals_count,
    COALESCE(SUM(d.total_amount), 0) AS total_sales
FROM users u
LEFT JOIN deals d ON u.id = d.manager_id
GROUP BY u.id, u.full_name
ORDER BY total_sales DESC;

-- 3. Клієнти з сумою угод вище порогу (clients + deals — INNER JOIN, GROUP BY, HAVING)
SELECT
    c.company_name,
    COUNT(d.id) AS deals_count,
    SUM(d.total_amount) AS total_sum
FROM clients c
INNER JOIN deals d ON c.id = d.client_id
GROUP BY c.id, c.company_name
HAVING SUM(d.total_amount) > 50000
ORDER BY total_sum DESC;

-- 4. Угоди і задачі разом (deals + tasks — FULL OUTER JOIN)
SELECT
    d.id AS deal_id,
    d.status AS deal_status,
    t.task_type,
    t.status AS task_status
FROM deals d
FULL OUTER JOIN tasks t ON d.id = t.deal_id
ORDER BY d.id NULLS LAST, t.id;

-- 5. Угоди з сумою більшою за середню (deals — підзапит у WHERE)
SELECT
    id,
    status,
    total_amount
FROM deals
WHERE total_amount > (SELECT AVG(total_amount) FROM deals)
ORDER BY total_amount DESC;

-- 6. Менеджери та кількість їхніх угод (users — підзапит у SELECT)
SELECT
    u.full_name,
    (SELECT COUNT(*) FROM deals d WHERE d.manager_id = u.id) AS deals_count
FROM users u
ORDER BY deals_count DESC;
