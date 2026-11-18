-- ============================================================================
-- ЛАБОРАТОРНА РОБОТА №3: МАНІПУЛЮВАННЯ ДАНИМИ SQL (OLTP)
-- Студенти групи ІМ-55: Матвіїв Р. С., Фалінський К. П.
-- ============================================================================

-- ============================================================================
-- БЛОК 1. ОПЕРАТОРИ SELECT (ОТРИМАННЯ ТА ФІЛЬТРАЦІЯ ДАНИХ)
-- ============================================================================

-- Запит 1.1. Отримання списку європейських серверів із місткістю понад 10 000 гравців
SELECT server_id, name, max_capacity
FROM Server
WHERE region = 'Europe' AND max_capacity > 10000
ORDER BY max_capacity DESC;

-- Запит 1.2. Пошук гравців високого рівня (level >= 20) та їхнього рейтингу
SELECT player_id, nickname, email, level, rating
FROM Player
WHERE level >= 20 AND rating >= 1700
ORDER BY rating DESC;

-- Запит 1.3. Фільтрація каталогу предметів: вибір усіх кораблів (категорія 'Ship')
SELECT item_id, name, characteristics
FROM Item
WHERE category = 'Ship';

-- Запит 1.4. Перевірка інвентарю конкретного гравця (player_id = 1)
SELECT player_id, item_id, quantity, item_level, acquired_date
FROM Player_Inventory
WHERE player_id = 1;

-- Запит 1.5. Пошук ресурсів в інвентарі гравців (де рівень предмета не застосовується: item_level IS NULL)
SELECT player_id, item_id, quantity, acquired_date
FROM Player_Inventory
WHERE item_level IS NULL AND quantity >= 400;

-- Запит 1.6. Вибірка тривалих матчів (понад 900 секунд), проведених на сервері 1
SELECT match_id, server_id, match_date, duration
FROM Match
WHERE server_id = 1 AND duration > 900
ORDER BY match_date DESC;

-- Запит 1.7. Отримання переможних виступів гравців із високою результативністю (score > 2200)
SELECT match_id, player_id, result, score, kills, deaths, resources_earned
FROM Match_Player
WHERE result = 'Victory' AND score > 2200;


-- ============================================================================
-- БЛОК 2. ОПЕРАТОРИ INSERT (ДОДАВАННЯ НОВИХ ЗАПИСІВ — OLTP-ОПЕРАЦІЇ)
-- ============================================================================

-- Запит 2.1. Додавання нового регіонального сервера
INSERT INTO Server (name, region, max_capacity)
VALUES ('EU-North-3', 'Europe', 14000)
RETURNING server_id, name, region, max_capacity;

-- Перевірка доданого сервера
SELECT server_id, name, region, max_capacity
FROM Server
WHERE name = 'EU-North-3';

-- Запит 2.2. Реєстрація двох нових гравців (один із яких буде тестовим для подальшого видалення)
INSERT INTO Player (server_id, nickname, email, level, rating)
VALUES
    (1, 'KpiAdmiral', 'admiral.kpi@example.com', 10, 1250),
    (5, 'TempBot_99', 'tempbot99@example.com', 1, 1000)
RETURNING player_id, nickname, server_id, level, rating;

-- Перевірка доданих гравців
SELECT player_id, nickname, email, server_id, level, rating
FROM Player
WHERE nickname IN ('KpiAdmiral', 'TempBot_99');

-- Запит 2.3. Додавання нового предмета в каталог (французький танк/техніка або персонаж)
INSERT INTO Item (name, category, characteristics)
VALUES ('Clorinde', 'Character', 'Champion Duelist, Electro element, high-speed lunge attack')
RETURNING item_id, name, category;

-- Перевірка каталогу предметів
SELECT item_id, name, category, characteristics
FROM Item
WHERE name = 'Clorinde';

-- Запит 2.4. Додавання предметів в інвентар гравців
INSERT INTO Player_Inventory (player_id, item_id, quantity, item_level, acquired_date)
VALUES
    (5, 1, 1, 5, CURRENT_DATE),      -- Гравець CyberPartner отримує корабель Napoli 5-го рівня
    (1, 6, 1, 1, CURRENT_DATE),      -- Гравець Rostislav77 отримує персонажа Clorinde 1-го рівня
    (5, 5, 100, NULL, CURRENT_DATE); -- Гравець CyberPartner отримує 100 одиниць ресурсу Steel_Ingot

-- Перевірка оновленого інвентарю для гравців 1 та 5
SELECT player_id, item_id, quantity, item_level, acquired_date
FROM Player_Inventory
WHERE player_id IN (1, 5)
ORDER BY player_id, item_id;

-- Запит 2.5. Реєстрація нового матчу та статистики його учасників
INSERT INTO Match (server_id, match_date, duration)
VALUES (1, '2026-10-05 20:00:00', 980)
RETURNING match_id, server_id, match_date, duration;

INSERT INTO Match_Player (match_id, player_id, result, score, resources_earned, kills, deaths)
VALUES
    (6, 1, 'Victory', 2950, 180, 6, 1),
    (6, 2, 'Victory', 2400, 140, 3, 1),
    (6, 5, 'Defeat',  1150,  40, 0, 2);

-- Перевірка записів нового матчу (match_id = 6)
SELECT match_id, player_id, result, score, resources_earned, kills, deaths
FROM Match_Player
WHERE match_id = 6;


-- ============================================================================
-- БЛОК 3. ОПЕРАТОРИ UPDATE (ОНОВЛЕННЯ ІСНУЮЧИХ ДАНИХ ІЗ ПЕРЕВІРКОЮ WHERE)
-- ============================================================================

-- Запит 3.1. Підвищення рівня та рейтингу гравця 'Rostislav77' після перемоги в матчі
-- Крок 1: Попередня перевірка запису через SELECT
SELECT player_id, nickname, level, rating
FROM Player
WHERE player_id = 1;

-- Крок 2: Виконання UPDATE
UPDATE Player
SET level = level + 1,
    rating = rating + 35
WHERE player_id = 1;

-- Крок 3: Перевірка результату після UPDATE
SELECT player_id, nickname, level, rating
FROM Player
WHERE player_id = 1;

-- Запит 3.2. Прокачування рівня предмета (корабля 'Napoli', item_id = 1) в інвентарі гравця 1
-- Крок 1: Попередня перевірка
SELECT player_id, item_id, quantity, item_level
FROM Player_Inventory
WHERE player_id = 1 AND item_id = 1;

-- Крок 2: Виконання UPDATE
UPDATE Player_Inventory
SET item_level = item_level + 2
WHERE player_id = 1 AND item_id = 1;

-- Крок 3: Перевірка результату
SELECT player_id, item_id, quantity, item_level
FROM Player_Inventory
WHERE player_id = 1 AND item_id = 1;

-- Запит 3.3. Розширення максимальної місткості тестового сервера в Києві ('UA-Kyiv-Test')
-- Крок 1: Попередня перевірка
SELECT server_id, name, max_capacity
FROM Server
WHERE name = 'UA-Kyiv-Test';

-- Крок 2: Виконання UPDATE
UPDATE Server
SET max_capacity = 8000
WHERE name = 'UA-Kyiv-Test';

-- Крок 3: Перевірка результату
SELECT server_id, name, max_capacity
FROM Server
WHERE name = 'UA-Kyiv-Test';

-- Запит 3.4. Транзакційне нарахування здобутих у матчі ресурсів (Steel_Ingot, item_id = 5)
-- та коригування очок гравця в межах єдиної OLTP-транзакції
BEGIN;

UPDATE Match_Player
SET score = 3050,
    resources_earned = 200
WHERE match_id = 6 AND player_id = 1;

UPDATE Player_Inventory
SET quantity = quantity + 200
WHERE player_id = 1 AND item_id = 5;

COMMIT;

-- Перевірка балансу ресурсів гравця 1 та його статистики у матчі 6 після транзакції
SELECT player_id, item_id, quantity
FROM Player_Inventory
WHERE player_id = 1 AND item_id = 5;

SELECT match_id, player_id, score, resources_earned
FROM Match_Player
WHERE match_id = 6 AND player_id = 1;


-- ============================================================================
-- БЛОК 4. ОПЕРАТОРИ DELETE (БЕЗПЕЧНЕ ВИДАЛЕННЯ ДАНИХ ІЗ ПЕРЕВІРКОЮ WHERE)
-- ============================================================================

-- Запит 4.1. Видалення помилкового/тестового запису участі гравця 5 у матчі 6
-- Крок 1: Попередня перевірка запису, який буде видалено
SELECT match_id, player_id, result, score
FROM Match_Player
WHERE match_id = 6 AND player_id = 5;

-- Крок 2: Безпечне видалення за складеним первинним ключем
DELETE FROM Match_Player
WHERE match_id = 6 AND player_id = 5;

-- Крок 3: Перевірка, що запис зник, а інші учасники матчу 6 залишилися
SELECT match_id, player_id, result, score
FROM Match_Player
WHERE match_id = 6;

-- Запит 4.2. Видалення витраченого ресурсу (item_id = 5) з інвентарю гравця 5
-- Крок 1: Попередня перевірка
SELECT player_id, item_id, quantity
FROM Player_Inventory
WHERE player_id = 5 AND item_id = 5;

-- Крок 2: Виконання DELETE
DELETE FROM Player_Inventory
WHERE player_id = 5 AND item_id = 5;

-- Крок 3: Перевірка інвентарю гравця 5
SELECT player_id, item_id, quantity, item_level
FROM Player_Inventory
WHERE player_id = 5;

-- Запит 4.3. Видалення тимчасового тестового облікового запису 'TempBot_99'
-- Крок 1: Попередня перевірка
SELECT player_id, nickname, email
FROM Player
WHERE nickname = 'TempBot_99';

-- Крок 2: Виконання DELETE
DELETE FROM Player
WHERE nickname = 'TempBot_99';

-- Крок 3: Перевірка відсутності видаленого рядка
SELECT player_id, nickname, email
FROM Player
WHERE nickname = 'TempBot_99';


-- ============================================================================
-- БЛОК 5. ФІНАЛЬНА ПЕРЕВІРКА СТАНУ ТАБЛИЦЬ (КОЖНА МІСТИТЬ >= 5 РЯДКІВ)
-- ============================================================================
SELECT server_id, name, region, max_capacity FROM Server ORDER BY server_id;
SELECT player_id, server_id, nickname, email, level, rating FROM Player ORDER BY player_id;
SELECT item_id, name, category, characteristics FROM Item ORDER BY item_id;
SELECT player_id, item_id, quantity, item_level, acquired_date FROM Player_Inventory ORDER BY player_id, item_id;
SELECT match_id, server_id, match_date, duration FROM Match ORDER BY match_id;
SELECT match_id, player_id, result, score, resources_earned, kills, deaths FROM Match_Player ORDER BY match_id, player_id;