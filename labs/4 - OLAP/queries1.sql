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