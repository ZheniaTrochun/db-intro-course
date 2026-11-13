-- 1 частина

--Всі гравці, що грають правою рукою з України
SELECT *
FROM Players p
WHERE p.plays_hand = 'Right' AND p.country_code = 'UKR'

--Знайти назви турнірів, які є Grand Slam
SELECT t.tournament_name
FROM Tournaments t
WHERE t.category = 'Grand Slam'

--Вивести імена гравців, які перейшли у професійний спорт після 2016 року
SELECT p.first_name || ' ' || p.last_name AS full_name
FROM Players p
WHERE p.turning_pro_year >= 2016

--Додавання нового гравця в таблицю
INSERT INTO Players (player_id, first_name, last_name, country_code, date_of_birth, birth_place, height_cm, plays_hand, back_hand, photo_url, turning_pro_year, career_status) 
VALUES ('44444444-4444-4444-4444-444444444444', 'Dayana', 'Yastremska', 'UKR', '2000-05-15', 'Odesa', 175, 'Right', 'Two-handed', 'https://example.com/yastremska.jpg', 2016, 'Active');

--Додавання запису про ранк нового гравця
INSERT INTO PlayerRankingHistory (ranking_id, player_id, rank, points, ranking_date) 
VALUES ('f4eebc99-9c0b-4ef8-bb6d-6bb9bd380004', '44444444-4444-4444-4444-444444444444', 32, 1650, '2026-10-29');

--Оновлення інформації про кількість очок у гравця
UPDATE PlayerRankingHistory
SET points = 5400 
WHERE player_id = '11111111-1111-1111-1111-111111111111';

--Оновлення пошти для користувача
UPDATE Users 
SET email = 'new_anna_email@tennis.com' 
WHERE username = 'admin_anna';

--Видалення користувача за юзернеймом
DELETE FROM Users 
WHERE username = 'sport_journalist';

--Видалення інформації про статистику кокретного гравця за конкретний матч
DELETE FROM PlayerMatchStatistics 
WHERE match_id = 'e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22' 
  AND player_id = '11111111-1111-1111-1111-111111111111';