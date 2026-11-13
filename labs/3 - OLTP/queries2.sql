-- Select
-- 1: Вибрати з таблиці кортів усі майданчики з назвою "Center Court"
SELECT * FROM Courts WHERE court_name = 'Center Court';

-- 2: Знайти в таблиці матчів усі поєдинки зі статусом завершених
SELECT * FROM Matches WHERE status = 'Finished';

-- 3: Отримати список усіх гравців із активним статусом кар'єри
SELECT * FROM Players WHERE career_status = 'Active';



-- Insert
-- 1: Додати новий турнір до таблиці турнірів
INSERT INTO Tournaments (tournament_id, tournament_name, category, surface, country_code, city, start_date, end_date, year)
VALUES ('a1eeec99-9c0b-4ef8-bb6d-6bb9bd380111', 'Kyiv Open', 'WTA 250', 'Clay', 'UKR', 'Kyiv', '2026-06-01', '2026-06-07', 2026);

-- 2: Додати новий корт, прив'язавши його до щойно створеного турніру
INSERT INTO Courts (court_id, tournament_id, court_name)
VALUES ('b2eeec99-9c0b-4ef8-bb6d-6bb9bd380222', 'a1eeec99-9c0b-4ef8-bb6d-6bb9bd380111', 'Court 1');



-- Update
-- 1: Змінити показник загальної тривалості (у хвилинах) для конкретного матчу
UPDATE Matches 
SET duration_minutes = 135 
WHERE match_id = 'e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- 2: Оновити місто проведення для турніру
UPDATE Tournaments 
SET city = 'Lviv' 
WHERE tournament_id = 'a1eeec99-9c0b-4ef8-bb6d-6bb9bd380111';



-- Delete
-- 1: Видалити інформацію про конкретний сет матчу за його ID
DELETE FROM MatchSets 
WHERE set_id = 'd1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- 2: Видалити запис про титул гравця в турнірі за ідентифікатором зв'язку
DELETE FROM PlayerTitles 
WHERE title_id = 'b1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11';