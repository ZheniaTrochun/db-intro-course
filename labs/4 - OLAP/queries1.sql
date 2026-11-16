-- 1 частина

--Запити з агрегаційними функціями

--Визначити середню тривалість матчу та окрулити її до двух знаків після коми
SELECT ROUND(AVG(duration_minutes), 2) AS avg_minutes
FROM Matches

--Додатковий інсерт для перевірки запиту
INSERT INTO Players (player_id, first_name, last_name, country_code, date_of_birth, birth_place, height_cm, plays_hand, back_hand, photo_url, turning_pro_year, career_status) 
VALUES ('55555555-5555-5555-5555-555555555555', 'Anastasija', 'Sevastova', 'LAT', '1990-04-13', 'Liepaja', 169, 'Right', 'Two-handed', 'https://example.com/sevastova.jpg', 2006, 'Retired');

--Знайти кількість гравців за статусом кар'єри (активні/на пенсії)
SELECT career_status, COUNT(*) AS total_players
FROM Players
GROUP BY career_status

--Знайти максимальне, мінімальне та середнє значення кількості очок у гравців у записах рейтингів
SELECT MAX(points) AS max_points, MIN(points) AS min_points, ROUND(AVG(points), 2) AS avg_points
FROM PlayerRankingHistory

--Джоіни

--Вивести список усіх завершених фінальних матчів (назва турніру, прізвище переможця та назва корту)
SELECT tournament_name, last_name AS winner_surname, court_name
FROM Matches m
INNER JOIN Tournaments AS t ON m.tournament_id = t.tournament_id
INNER JOIN Players AS p ON m.winner_id = p.player_id
INNER JOIN Courts AS c ON m.court_id = c.court_id
WHERE m.status = 'Finished' AND m.round = 'Final'
ORDER BY tournament_name

--Вивести список усіх турнірів (назва турніру) і супутніх їм кортів через LEFT JOIN
SELECT t.tournament_name, c.court_name
FROM Tournaments t
LEFT JOIN Courts AS c ON t.tournament_id = c.tournament_id

--Підзапити

--Знайти інформацію про гравців, чий зріст перевищує середній зріст усіх тенісистів у таблиці
SELECT p.first_name || ' ' || p.last_name AS full_name, p.height_cm,
	(SELECT ROUND(AVG(height_cm), 2) AS avg_height FROM Players)
FROM Players p
WHERE height_cm > (
	SELECT ROUND(AVG(p.height_cm), 2)
	FROM Players p
)

--Вивести список турнірів, які належать до тієї ж категорії, що і турнір з назвою 'Wimbledon'
SELECT tournament_name
FROM Tournaments
WHERE category = (
	SELECT category
	FROM Tournaments
	WHERE tournament_name = 'Wimbledon'
)