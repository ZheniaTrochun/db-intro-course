-- SELECT

-- Отримання фільмів із прем'єрою від 2010 року
SELECT movie_id, title, release_year, duration_minutes 
FROM movie 
WHERE release_year >= 2010;

-- Отримання фільмів з оцінками 9 і 10 балів із відображенням імен користувачів та назв
SELECT r.rating_id, u.username, m.title, r.score, r.rated_at
FROM rating r
JOIN "user" u ON r.user_id = u.user_id
JOIN movie m ON r.movie_id = m.movie_id
WHERE r.score >= 9;

-- Отримання списку стрічок, які користувачі зберегли для перегляду пізніше ('WATCH_LATER')
SELECT u.username, m.title, s.status, s.updated_at
FROM user_movie_status s
JOIN "user" u ON s.user_id = u.user_id
JOIN movie m ON s.movie_id = m.movie_id
WHERE s.status = 'WATCH_LATER';

-- Вибірка всіх картин конкретного режисера (Christopher Nolan) через таблицю зв'язку
SELECT m.title, m.release_year, p.full_name AS director
FROM movie m
JOIN movie_director md ON m.movie_id = md.movie_id
JOIN person p ON md.person_id = p.person_id
WHERE p.full_name = 'Christopher Nolan';


-- INSERT

-- Реєстрація нового користувача
INSERT INTO "user" (user_id, username, email, password_hash)
VALUES ('e45ebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'serhii_cinema', 'serhii@example.com', '$2y$10$hashsample5');

-- Додавання нового фільму "Oppenheimer" (перевірка обмежень CHECK >= 1888 та CHECK > 0)
INSERT INTO movie (movie_id, title, release_year, duration_minutes, synopsis, poster_url)
VALUES ('b56fc10b-58cc-4372-a567-0e02b2c3d483', 'Oppenheimer', 2023, 180, 
        'The story of American scientist J. Robert Oppenheimer and his role in the Manhattan Project.', 
        'https://example.com/oppenheimer.jpg');

-- Зв'язування нового фільму з режисером (Christopher Nolan, person_id = 1)
INSERT INTO movie_director (movie_id, person_id)
VALUES ('b56fc10b-58cc-4372-a567-0e02b2c3d483', 1);

-- Зв'язування нового фільму з жанром (Drama, genre_id = 3)
INSERT INTO movie_genre (movie_id, genre_id)
VALUES ('b56fc10b-58cc-4372-a567-0e02b2c3d483', 3);

-- Додавання оцінки від нового користувача
INSERT INTO rating (user_id, movie_id, score)
VALUES ('e45ebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'b56fc10b-58cc-4372-a567-0e02b2c3d483', 10);

-- Додавання статусу перегляду від нового користувача
INSERT INTO user_movie_status (user_id, movie_id, status)
VALUES ('e45ebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'b56fc10b-58cc-4372-a567-0e02b2c3d483', 'WATCHED');






