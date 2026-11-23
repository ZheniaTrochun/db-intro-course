-- Запит 1.1: Знайти всі тайтли з оцінкою вище 8.50
SELECT title_id, title_name, type, score, release_date
FROM MediaItem
WHERE score > 8.50
ORDER BY score DESC;

-- Запит 1.2: Знайти всі завершені тайтли користувача з user_id = 1
SELECT m.title_name, ums.user_score, ums.user_status
FROM UserMediaStats ums
JOIN MediaItem m ON ums.title_id = m.title_id
WHERE ums.user_id = 1 AND ums.user_status = 'Completed';

-- Запит 1.3: Вивести всі тайтли в жанрі 'Sci-Fi' (через зв'язок M:N)
SELECT m.title_name, g.genre_name, m.score
FROM MediaItem m
JOIN MediaGenre mg ON m.title_id = mg.title_id
JOIN Genre g ON mg.genre_id = g.genre_id
WHERE g.genre_name = 'Sci-Fi';


-- Запит 2.1: Додавання нового користувача
INSERT INTO UserData (user_id, user_name, user_description) VALUES
	(6, 'cyber_otaku', 'Watching classic 2000s sci-fi and mecha anime.');

-- Перевірка
SELECT user_id, user_name, user_description
FROM UserData
WHERE user_id = 6;

-- Запит 2.2: Додавання нового тайтла в базу
INSERT INTO MediaItem (title_id, title_name, type, release_date, status, score) VALUES 
	(6, 'Serial Experiments Lain', 'TV', '1998-07-06', 'Finished', 8.09);

-- Прив'язка нового тайтла до жанрів (Psychological = 2, Sci-Fi = 4)
INSERT INTO MediaGenre (title_id, genre_id)
VALUES (6, 2), (6, 4);

-- Додавання тайтла в список перегляду нового користувача
INSERT INTO UserMediaStats (user_id, title_id, user_score, user_status)
VALUES (6, 6, NULL, 'Plan to Watch');

-- Перевірка
SELECT m.title_name, u.user_name, ums.user_status, ums.user_score
FROM UserMediaStats ums
JOIN MediaItem m ON ums.title_id = m.title_id
JOIN UserData u ON ums.user_id = u.user_id
WHERE ums.user_id = 6;


-- Запит 3.1: Оновлення статусу та виставлення оцінки
SELECT * FROM UserMediaStats WHERE user_id = 6 AND title_id = 6;

-- Виконуємо оновлення в межах транзакції
BEGIN;
UPDATE UserMediaStats
SET user_status = 'Completed',
    user_score = 9
WHERE user_id = 6 AND title_id = 6;
COMMIT;

-- Перевірка
SELECT user_id, title_id, user_score, user_status
FROM UserMediaStats
WHERE user_id = 6 AND title_id = 6;

-- Запит 3.2: Оновлення опису профілю користувача
UPDATE UserData
SET user_description = 'Huge fan of psychological thrillers and 90s cyberpunk.'
WHERE user_id = 6;

-- Перевірка
SELECT user_id, user_name, user_description
FROM UserData
WHERE user_id = 6;


-- Запит 4.1: Видалення запису зі списку перегляду користувача
SELECT * FROM UserMediaStats WHERE user_id = 6 AND title_id = 6;

DELETE FROM UserMediaStats
WHERE user_id = 6 AND title_id = 6;

-- Перевірка
SELECT * FROM UserMediaStats WHERE user_id = 6 AND title_id = 6;

-- Запит 4.2: Видалення тестового користувача та тайтла
DELETE FROM UserData WHERE user_id = 6;
DELETE FROM MediaItem WHERE title_id = 6;

-- Перевірка
SELECT user_id, user_name FROM UserData WHERE user_id = 6;
SELECT title_id, title_name FROM MediaItem WHERE title_id = 6;