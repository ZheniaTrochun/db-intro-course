-- Загальна кількість додатків у каталозі
SELECT COUNT(*) AS total_apps 
FROM app;

-- Загальний дохід платформи від усіх замовлень
SELECT SUM(total_amount) AS total_revenue 
FROM "order";

-- Середня ціна продукту на платформі
SELECT AVG(price) AS average_app_price 
FROM app;

-- Мінімальна та максимальна ціна серед усіх продуктів
SELECT MIN(price) AS min_price, MAX(price) AS max_price 
FROM app;

-- Кількість продуктів за кожним типом (game / dlc)
SELECT app_type, COUNT(*) AS count_per_type 
FROM app 
GROUP BY app_type;

-- Фільтрування груп: знайти продукти, які додавали у список бажань (wishlist) більше ніж 1 раз
SELECT app_id, COUNT(*) AS wishlist_count 
FROM wishlist 
GROUP BY app_id 
HAVING COUNT(*) > 1;

-- Знайти користувачів, які здійснили більше ніж 1 замовлення
SELECT user_id, COUNT(*) AS orders_count 
FROM "order" 
WHERE user_id IS NOT NULL 
GROUP BY user_id 
HAVING COUNT(*) > 1;

-- INNER JOIN: Перелік назв ігор разом із назвами їхніх видавців
SELECT a.title AS app_title, p.publisher_name 
FROM app a 
INNER JOIN publisher p ON a.publisher_id = p.publisher_id;

-- LEFT JOIN: Вивести всіх видавців та їхні ігри (включно з тими, у яких немає релізів)
SELECT p.publisher_name, a.title AS app_title 
FROM publisher p 
LEFT JOIN app a ON p.publisher_id = a.publisher_id;

-- CROSS JOIN: Декартовий добуток користувачів та категорій
SELECT u.username, c.category_name 
FROM "user" u 
CROSS JOIN category c;

-- Загальна сума грошей, витрачена кожним користувачем (User -> Order)
SELECT u.username, SUM(o.total_amount) AS total_spent 
FROM "user" u 
JOIN "order" o ON u.user_id = o.user_id 
GROUP BY u.username;

-- Загальна кількість ігор у кожній жанровій категорії (Category -> app_category -> App)
SELECT c.category_name, COUNT(ac.app_id) AS apps_in_category 
FROM category c 
LEFT JOIN app_category ac ON c.category_id = ac.category_id 
GROUP BY c.category_name;

-- Підзапит у WHERE: Знайти продукти, ціна яких вища за середню ціну в каталозі
SELECT title, price 
FROM app 
WHERE price > (SELECT AVG(price) FROM app);

-- Підзапит у SELECT: Вивести назву гри, ціну та різницю від середньої ціни каталогу
SELECT title, price, 
       (price - (SELECT AVG(price) FROM app)) AS price_diff_from_avg 
SELECT title, price, 
       (price - (SELECT AVG(price) FROM (SELECT price FROM app) AS sub)) AS price_diff_from_avg 
FROM app;

-- Підзапит у HAVING: Знайти категорії, де кількість ігор перевищує середню кількість по всіх категоріях
SELECT ac.category_id, COUNT(*) AS apps_count 
FROM app_category ac 
GROUP BY ac.category_id 
HAVING COUNT(*) > (
    SELECT AVG(sub.cnt) 
    FROM (SELECT COUNT(*) AS cnt FROM app_category GROUP BY category_id) sub
);

