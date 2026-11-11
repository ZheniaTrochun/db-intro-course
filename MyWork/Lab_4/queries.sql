-- ============================================
-- Lab 4: OLAP — Агрегація, GROUP BY, HAVING, JOIN
-- Проєкт: VideoHub (відеохостинг-платформа)
-- Степаненко Денис, ІМ-051
-- ============================================

-- ============================================
-- ДОДАТКОВІ ТЕСТОВІ ДАНІ ДЛЯ АНАЛІТИКИ
-- Базові дані з Lab 2 занадто рівномірні (у кожного автора
-- рівно 1 відео, у кожного відео рівно 1 коментар) —
-- агрегати та HAVING повертали б порожні результати.
-- Додаємо нерівномірність: у одного автора 3 відео,
-- в одного відео 3 коментарі, є користувач без відео.
-- ============================================

-- Новий користувач БЕЗ відео (для LEFT/FULL JOIN)
INSERT INTO "User" (id, email, username, password, google_id, avatar, banner, description) VALUES
    ('a1b2c3d4-0006-0000-0000-000000000006', 'guest@example.com', 'test_guest', 'hashed_pass_6', NULL, NULL, NULL, 'Just watching, not uploading yet.');

-- Ще 2 відео для denys_dev (тепер у нього 3 відео)
INSERT INTO "Video" (id, title, description, url, thumbnail, views, author_id) VALUES
    ('b2c3d4e5-0006-0000-0000-000000000006', 'Docker Compose in 15 Minutes', 'Quick start with Docker Compose for local dev.', 'https://cdn.videohub.com/videos/vid6.mp4', 'https://cdn.videohub.com/thumbs/vid6.jpg', 8500, 'a1b2c3d4-0001-0000-0000-000000000001'),
    ('b2c3d4e5-0007-0000-0000-000000000007', 'REST API Design Best Practices', 'How to design clean REST endpoints.', 'https://cdn.videohub.com/videos/vid7.mp4', 'https://cdn.videohub.com/thumbs/vid7.jpg', 23000, 'a1b2c3d4-0001-0000-0000-000000000001');

-- Ще 2 коментарі до першого відео (тепер у нього 3)
INSERT INTO "Comment" (id, text, user_id, video_id) VALUES
    ('c3d4e5f6-0006-0000-0000-000000000006', 'Saved me hours, thanks!', 'a1b2c3d4-0004-0000-0000-000000000004', 'b2c3d4e5-0001-0000-0000-000000000001'),
    ('c3d4e5f6-0007-0000-0000-000000000007', 'Waiting for part 2!', 'a1b2c3d4-0005-0000-0000-000000000005', 'b2c3d4e5-0001-0000-0000-000000000001');

-- Ще 3 лайки (різна кількість лайків на відео)
INSERT INTO "Like" (user_id, video_id) VALUES
    ('a1b2c3d4-0002-0000-0000-000000000002', 'b2c3d4e5-0003-0000-0000-000000000003'),
    ('a1b2c3d4-0004-0000-0000-000000000004', 'b2c3d4e5-0002-0000-0000-000000000002'),
    ('a1b2c3d4-0006-0000-0000-000000000006', 'b2c3d4e5-0001-0000-0000-000000000001');

-- ============================================
-- БАЗОВА АГРЕГАЦІЯ
-- Усі п'ять агрегатів одним проходом по таблиці —
-- один скан замість п'яти окремих запитів.
-- ============================================

SELECT COUNT(*)                    AS total_videos,
       COUNT(DISTINCT author_id)   AS unique_authors,
       SUM(views)                  AS total_views,
       MIN(views)                  AS min_views,
       MAX(views)                  AS max_views,
       ROUND(AVG(views), 0)        AS avg_views
FROM "Video";

-- ============================================
-- ГРУПУВАННЯ (GROUP BY)
-- ============================================

-- 1. Статистика кожного автора: кількість відео + сумарні
-- перегляди (обидва завдання одним запитом)
SELECT u.username,
       COUNT(v.id)  AS video_count,
       SUM(v.views) AS total_views
FROM "User" u
INNER JOIN "Video" v ON u.id = v.author_id
GROUP BY u.username
ORDER BY total_views DESC;

-- 2. Кількість коментарів для кожного відео
-- (LEFT JOIN — відео без коментарів теж у списку, з 0)
SELECT v.title, COUNT(c.id) AS comment_count
FROM "Video" v
LEFT JOIN "Comment" c ON v.id = c.video_id
GROUP BY v.id, v.title
ORDER BY comment_count DESC;

-- ============================================
-- ФІЛЬТРУВАННЯ ГРУП (HAVING)
-- ============================================

-- 1. Автори з більш ніж 1 відео
SELECT u.username, COUNT(v.id) AS video_count
FROM "User" u
INNER JOIN "Video" v ON u.id = v.author_id
GROUP BY u.username
HAVING COUNT(v.id) > 1;

-- 2. Відео з більш ніж 2 коментарями
SELECT v.title, COUNT(c.id) AS comment_count
FROM "Video" v
INNER JOIN "Comment" c ON v.id = c.video_id
GROUP BY v.id, v.title
HAVING COUNT(c.id) > 2;

-- 3. Автори з сумарними переглядами > 20000
SELECT u.username, SUM(v.views) AS total_views
FROM "User" u
INNER JOIN "Video" v ON u.id = v.author_id
GROUP BY u.username
HAVING SUM(v.views) > 20000;

-- ============================================
-- JOIN (різні типи з'єднань)
-- ============================================

-- 1. INNER JOIN — відео з іменами авторів (тільки збіги)
SELECT v.title, u.username AS author
FROM "Video" v
INNER JOIN "User" u ON v.author_id = u.id;

-- 2. LEFT JOIN — усі користувачі; ті, хто без відео, мають NULL
SELECT u.username, v.title
FROM "User" u
LEFT JOIN "Video" v ON v.author_id = u.id;

-- 2a. Анти-джойн: користувачі БЕЗ жодного відео
-- (test_guest — єдиний, хто ще нічого не завантажив)
SELECT u.username
FROM "User" u
LEFT JOIN "Video" v ON v.author_id = u.id
WHERE v.id IS NULL;

-- 3. FULL OUTER JOIN — усі користувачі та всі відео.
-- У нашій схемі відео без автора неможливе (author_id NOT NULL),
-- тому FULL тут збігається з LEFT: додаткові NULL-рядки
-- з'являються лише з боку користувачів без відео.
SELECT u.username, v.title
FROM "User" u
FULL OUTER JOIN "Video" v ON v.author_id = u.id;

-- 4. CROSS JOIN — всі комбінації користувачів та відео
-- (potential audience: кому яку рекомендацію показати)
SELECT u.username AS potential_viewer, v.title
FROM "User" u
CROSS JOIN "Video" v;

-- ============================================
-- БАГАТОТАБЛИЧНА АГРЕГАЦІЯ
-- ============================================

-- 1. Топ-3 автори за сумарними переглядами
-- (JOIN + GROUP BY + ORDER BY + LIMIT)
SELECT u.username, SUM(v.views) AS total_views
FROM "User" u
INNER JOIN "Video" v ON u.id = v.author_id
GROUP BY u.username
ORDER BY total_views DESC
LIMIT 3;

-- 2. Кожне відео з кількістю лайків та коментарів.
-- Подвійний LEFT JOIN розмножує рядки (лайки × коментарі),
-- тому рахуємо COUNT(DISTINCT ...) — інакше COUNT бреше.
SELECT v.title,
       COUNT(DISTINCT l.user_id) AS like_count,
       COUNT(DISTINCT c.id) AS comment_count
FROM "Video" v
LEFT JOIN "Like" l ON l.video_id = v.id
LEFT JOIN "Comment" c ON c.video_id = v.id
GROUP BY v.id, v.title
ORDER BY like_count DESC, comment_count DESC;

-- 3. Підзапит: автори, чий СЕРЕДНІЙ перегляд відео
-- вищий за загальний середній по платформі
SELECT u.username, ROUND(AVG(v.views), 0) AS avg_views
FROM "User" u
INNER JOIN "Video" v ON u.id = v.author_id
GROUP BY u.username
HAVING AVG(v.views) > (SELECT AVG(views) FROM "Video");
