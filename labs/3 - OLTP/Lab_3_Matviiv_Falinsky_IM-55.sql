-- ЛАБОРАТОРНА РОБОТА №3. Маніпулювання даними SQL (OLTP)
-- Схема та тестові дані з лабораторної №2 (перед запуском виконати скрипт ЛР №2).


-- ===================== 1. SELECT =====================

-- 1.1 Європейські сервери з місткістю понад 10000
SELECT name, region, max_capacity
FROM Server
WHERE region = 'Europe' AND max_capacity > 10000
ORDER BY max_capacity DESC;

-- 1.2 Гравці з рейтингом від 1500 до 1900
SELECT nickname, level, rating
FROM Player
WHERE rating BETWEEN 1500 AND 1900;

-- 1.3 Предмети категорій Ship та Character
SELECT name, category
FROM Item
WHERE category IN ('Ship', 'Character');

-- 1.4 Предмети, які не є ресурсами (стандартна нерівність <>)
SELECT name, category
FROM Item
WHERE category <> 'Resource';

-- 1.5 Гравці, чий нікнейм починається на R
SELECT nickname
FROM Player
WHERE nickname LIKE 'R%';

-- 1.6 Предмети в інвентарі без рівня (ресурси)
SELECT player_id, item_id, quantity
FROM Player_Inventory
WHERE item_level IS NULL;

-- 1.7 Унікальні регіони серверів
SELECT DISTINCT region
FROM Server
ORDER BY region;

-- 1.8 Базова статистика рейтингу гравців
SELECT COUNT(*) AS players,
       MIN(rating) AS min_rating,
       MAX(rating) AS max_rating,
       AVG(rating) AS avg_rating
FROM Player;


-- ===================== 2. INSERT =====================

-- 2.1 Додавання нового сервера (повертає server_id = 6)
INSERT INTO Server (name, region, max_capacity)
VALUES ('EU-North-3', 'Europe', 14000)
RETURNING server_id;

-- Дізнаємося server_id для EU-Central-1 перед вставкою гравця (server_id = 1)
SELECT server_id, name
FROM Server
WHERE name = 'EU-Central-1';

-- 2.2 Додавання тестового гравця (level і rating отримають DEFAULT; повертає player_id = 6)
INSERT INTO Player (server_id, nickname, email)
VALUES (1, 'TempBot_99', 'tempbot99@example.com')
RETURNING player_id;

-- Дізнаємося item_id для Steel_Ingot (item_id = 5)
SELECT item_id, name
FROM Item
WHERE name = 'Steel_Ingot';

-- 2.3 Видача ресурсу новому гравцю (player_id = 6, item_id = 5)
INSERT INTO Player_Inventory (player_id, item_id, quantity, item_level, acquired_date)
VALUES (6, 5, 100, NULL, '2026-10-05');

-- 2.4 Створення нового матчу на сервері 1 (повертає match_id = 6)
INSERT INTO Match (server_id, match_date, duration)
VALUES (1, '2026-10-05 20:00:00', 980)
RETURNING match_id;

-- 2.5 Запис результату гравця 6 у матчі 6
INSERT INTO Match_Player (match_id, player_id, result, score, resources_earned, kills, deaths)
VALUES (6, 6, 'Defeat', 1150, 40, 0, 2);

-- Перевірка вставлених записів
SELECT server_id, name, max_capacity FROM Server WHERE server_id = 6;
SELECT player_id, nickname, level, rating FROM Player WHERE player_id = 6;
SELECT player_id, item_id, quantity, item_level FROM Player_Inventory WHERE player_id = 6;
SELECT match_id, player_id, result, score FROM Match_Player WHERE player_id = 6;


-- ===================== 3. UPDATE =====================

-- 3.1 Оновлення рівня та рейтингу гравця Rostislav77 у транзакції
SELECT nickname, level, rating
FROM Player
WHERE nickname = 'Rostislav77';

BEGIN;
UPDATE Player
SET level = 26, rating = 1885
WHERE nickname = 'Rostislav77';

SELECT nickname, level, rating
FROM Player
WHERE nickname = 'Rostislav77';
COMMIT;

-- 3.2 Демонстрація ROLLBACK: тимчасова зміна місткості сервера та скасування
BEGIN;
UPDATE Server
SET max_capacity = 8000
WHERE name = 'UA-Kyiv-Test';

SELECT name, max_capacity
FROM Server
WHERE name = 'UA-Kyiv-Test';
ROLLBACK;

SELECT name, max_capacity
FROM Server
WHERE name = 'UA-Kyiv-Test';


-- ===================== 4. DELETE =====================

-- Перевірка тестового гравця перед видаленням
SELECT player_id, nickname
FROM Player
WHERE player_id = 6;

-- Видалення тестових даних: спочатку дочірні таблиці, потім батьківські
BEGIN;
DELETE FROM Match_Player WHERE player_id = 6;
DELETE FROM Player_Inventory WHERE player_id = 6;
DELETE FROM Player WHERE player_id = 6;
DELETE FROM Match WHERE match_id = 6;
DELETE FROM Server WHERE server_id = 6;

-- Перевірка, що гравця видалено
SELECT player_id, nickname
FROM Player
WHERE player_id = 6;
COMMIT;


-- ===================== 5. Перевірка стану таблиць =====================

SELECT server_id, name, region, max_capacity FROM Server ORDER BY server_id;
SELECT player_id, nickname, level, rating FROM Player ORDER BY player_id;
SELECT item_id, name, category FROM Item ORDER BY item_id;
SELECT player_id, item_id, quantity, item_level FROM Player_Inventory ORDER BY player_id, item_id;
SELECT match_id, server_id, match_date, duration FROM Match ORDER BY match_id;
SELECT match_id, player_id, result, score FROM Match_Player ORDER BY match_id, player_id;