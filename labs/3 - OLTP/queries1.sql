-- 1 частина --

--Всі гравці, що грають правою рукою з України--
SELECT *
FROM Players p
WHERE p.plays_hand = 'Right' AND p.country_code = 'UKR'

--Знайти назви турнірів, які є Grand Slam--
SELECT t.tournament_name
FROM Tournaments t
WHERE t.category = 'Grand Slam'

--Вивести імена гравців, які перейшли у професійний спорт після 2016 року--
SELECT p.first_name || ' ' || p.last_name AS full_name
FROM Players p
WHERE p.turning_pro_year >= 2016