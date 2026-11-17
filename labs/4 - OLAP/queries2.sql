-- Функції агрегації та групування

-- 1. Загальна кількість зіграних сетів та максимальна кількість геймів першого гравця
SELECT 
    COUNT(*) AS total_sets, 
    MAX(player1_games) AS max_player1_games 
FROM MatchSets;


-- 2. Згрупувати турніри за покриттям кортів та порахувати кількість
SELECT 
    surface, 
    COUNT(*) AS tournament_count 
FROM Tournaments 
GROUP BY surface;


-- 3. Загальна кількість ейсів для кожного гравця (відсортовано за спаданням)
SELECT 
    player_id, 
    SUM(aces) AS total_aces 
FROM PlayerMatchStatistics 
GROUP BY player_id 
ORDER BY total_aces DESC;



-- Об'єднання таблиць JOIN

-- 1. Прізвище гравця та назва турніру, де він виграв титул (INNER JOIN)
SELECT 
    p.last_name, 
    t.tournament_name 
FROM PlayerTitles pt
JOIN Players p ON pt.player_id = p.player_id
JOIN Tournaments t ON pt.tournament_id = t.tournament_id;


-- 2. Список усіх гравців та їхніх тренерів (LEFT JOIN)
SELECT 
    p.first_name AS player_first_name, 
    p.last_name AS player_last_name, 
    c.first_name AS coach_first_name, 
    c.last_name AS coach_last_name
FROM Players p
LEFT JOIN Coaches c ON p.player_id = c.player_id;



-- Підзапити

-- 1. Турніри у тій же країні, де народилася Коко Гауфф (підзапит у WHERE)
SELECT * 
FROM Tournaments 
WHERE country_code = (
    SELECT country_code 
    FROM Players 
    WHERE first_name = 'Coco' AND last_name = 'Gauff'
);


-- 2. Матчі з найбільшою тривалістю в базі даних (підзапит із MAX у WHERE)
SELECT * 
FROM Matches 
WHERE duration_minutes = (
    SELECT MAX(duration_minutes) 
    FROM Matches
);