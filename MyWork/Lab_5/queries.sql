-- ============================================
-- Lab 5: Нормалізація — аналіз 1NF/2NF/3NF
-- Проєкт: VideoHub (відеохостинг-платформа)
-- Степаненко Денис, ІМ-051
-- ============================================

-- ============================================
-- АНАЛІЗ ПОТОЧНОЇ СХЕМИ
-- ============================================

-- 1. Структура всіх таблиць: колонки та типи
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('User', 'Video', 'Comment', 'Like', 'Subscription')
ORDER BY table_name, ordinal_position;

-- 2. Усі обмеження схеми (PK, FK, CHECK, UNIQUE)
SELECT conrelid::regclass AS table_name, conname, contype, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text, contype;

-- ============================================
-- ПЕРЕВІРКА 1NF — АТОМАРНІСТЬ
-- ============================================

-- 1NF: кожна комірка містить одне атомарне значення.
-- У схемі VideoHub немає списків у комірках: теги, телефони,
-- ролі зберігаються окремими таблицями/рядками, не через кому.
-- Перевірка: жодна колонка не є масивом.
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND data_type = 'ARRAY'
  AND table_name IN ('User', 'Video', 'Comment', 'Like', 'Subscription');
-- Очікуємо: 0 рядків — порушень 1NF немає.

-- ============================================
-- ПЕРЕВІРКА 2NF — ЧАСТКОВІ ЗАЛЕЖНОСТІ
-- ============================================

-- 2NF стосується таблиць із композитним ключем: Like(user_id, video_id)
-- та Subscription(subscriber_id, channel_id).
-- Не-ключовий атрибут цих таблиць — created_at — залежить від ПАРИ
-- (факт лайка існує саме для пари юзер+відео), а не від частини ключа.
-- Часткових залежностей немає → 2NF виконано.

-- Демонстрація: created_at має сенс лише для повної пари
SELECT user_id, video_id, created_at FROM "Like" LIMIT 3;

-- ============================================
-- ПЕРЕВІРКА 3NF — ТРАНЗИТИВНІ ЗАЛЕЖНОСТІ
-- ============================================

-- 3NF: не-ключовий атрибут не залежить від іншого не-ключового.
-- У "Video" немає author_email/author_name — тільки author_id (FK).
-- Email живе в "User" і змінюється в ОДНОМУ місці.
-- Перевірка: у Video немає колонок, що дублюють атрибути User.
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'Video'
  AND column_name LIKE 'author_%';
-- Очікуємо: лише author_id.

-- ============================================
-- «ХВОРА» ТАБЛИЦЯ — ДЕНОРМАЛІЗОВАНИЙ ПРИКЛАД
-- Головна схема чиста за дизайном, тому порушення створюємо
-- навмисно — і лікуємо. Три діагнози в одній таблиці:
--   1) tags списком через кому          — порушення 1NF
--   2) category_and_subcategory 'A/B'   — порушення 1NF
--   3) author_username + author_email   — порушення 3NF
--      (транзитивно: id → author_id → username/email)
-- Обмежень (FK/CHECK) немає — частина «хвороби».
-- ============================================

CREATE TABLE "VideoDenormalized" (
    id                       UUID PRIMARY KEY,
    title                    VARCHAR(255) NOT NULL,
    url                      VARCHAR(500) NOT NULL,
    views                    INTEGER NOT NULL DEFAULT 0,
    author_id                UUID,
    author_username          VARCHAR(100) NOT NULL,
    author_email             VARCHAR(255) NOT NULL,
    tags                     TEXT NOT NULL,
    category_and_subcategory VARCHAR(100) NOT NULL
);

INSERT INTO "VideoDenormalized"
    (id, title, url, views, author_id, author_username, author_email, tags, category_and_subcategory)
VALUES
    ('b2c3d4e5-0001-0000-0000-000000000001', 'PostgreSQL Tutorial for Beginners',
     'https://cdn.videohub.com/videos/vid1.mp4', 15420,
     'a1b2c3d4-0001-0000-0000-000000000001', 'denys_dev', 'denys@example.com',
     'postgresql,database,tutorial,beginners', 'Tech/Databases'),
    ('b2c3d4e5-0002-0000-0000-000000000002', 'Elden Ring — Final Boss Fight',
     'https://cdn.videohub.com/videos/vid2.mp4', 89300,
     'a1b2c3d4-0002-0000-0000-000000000002', 'maria_gaming', 'maria@example.com',
     'gaming,eldenring,rpg,bossfight', 'Gaming/RPG'),
    ('b2c3d4e5-0003-0000-0000-000000000003', 'How to Make Perfect Pasta Carbonara',
     'https://cdn.videohub.com/videos/vid3.mp4', 5230,
     'a1b2c3d4-0003-0000-0000-000000000003', 'oleg_cook', 'oleg@example.com',
     'cooking,pasta,italian,recipe', 'Cooking/Italian'),
    ('b2c3d4e5-0004-0000-0000-000000000004', 'Exploring Tokyo — Shibuya at Night',
     'https://cdn.videohub.com/videos/vid4.mp4', 32100,
     'a1b2c3d4-0004-0000-0000-000000000004', 'anna_travel', 'anna@example.com',
     'travel,tokyo,japan,nightwalk', 'Travel/Japan'),
    ('b2c3d4e5-0005-0000-0000-000000000005', 'Acoustic Guitar Cover — Wonderwall',
     'https://cdn.videohub.com/videos/vid5.mp4', 12750,
     'a1b2c3d4-0005-0000-0000-000000000005', 'max_music', 'max@example.com',
     'music,guitar,cover', 'Music/Cover');

SELECT * FROM "VideoDenormalized";

-- ============================================
-- ДІАГНОСТИКА — ЗАПИТИ-ДІАГНОЗИ
-- ============================================

-- Діагноз 1: пошук по списку тегів — LIKE-хак.
-- Підрядковий збіг знайде і 'database' всередині 'databases';
-- індексу немає; порядок тегів у списку ламає точне порівняння.
SELECT title, tags FROM "VideoDenormalized"
WHERE tags LIKE '%database%';

-- Діагноз 2: дублі довідника автора — email повторюється
-- у кожному відео автора. Зміна email = оновити всі рядки,
-- пропустити один = розсинхрон (аномалія оновлення).
SELECT author_username, author_email, COUNT(*) AS videos
FROM "VideoDenormalized"
GROUP BY author_username, author_email;

-- Діагноз 3: два факти в одній комірці — запит «усі відео
-- категорії Tech» змушений різати рядок:
SELECT title, split_part(category_and_subcategory, '/', 1) AS category
FROM "VideoDenormalized"
WHERE split_part(category_and_subcategory, '/', 1) = 'Tech';

-- ============================================
-- ЛІКУВАННЯ КРОК 1 — M:N ДЛЯ ТЕГІВ
-- Tag — довідник (ім'я унікальне, живе один раз);
-- VideoTag — junction зі складеним PK: пара і є
-- ідентичність зв'язку. CASCADE обидва — сиріт не буває.
-- ============================================

CREATE TABLE "Tag" (
    id   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE "VideoTag" (
    video_id UUID NOT NULL REFERENCES "Video"(id) ON DELETE CASCADE,
    tag_id   UUID NOT NULL REFERENCES "Tag"(id) ON DELETE CASCADE,
    PRIMARY KEY (video_id, tag_id)
);

-- ============================================
-- ЛІКУВАННЯ КРОК 2 — ALTER-ХІРУРГІЯ НА ЖИВІЙ ТАБЛИЦІ
-- Золоте правило міграції: спочатку ADD нового, потім
-- перенесення даних, і лише потім DROP старого.
-- ============================================

-- 2a. ADD атомарних колонок
ALTER TABLE "VideoDenormalized" ADD COLUMN category    VARCHAR(50);
ALTER TABLE "VideoDenormalized" ADD COLUMN subcategory VARCHAR(50);

-- 2b. Перенесення даних: split_part ріже 'Tech/Databases'
-- на дві атомарні частини
UPDATE "VideoDenormalized"
SET category    = split_part(category_and_subcategory, '/', 1),
    subcategory = split_part(category_and_subcategory, '/', 2);

-- Перевірка перенесення
SELECT title, category_and_subcategory, category, subcategory
FROM "VideoDenormalized";

-- 2c. DROP старих: складеної колонки і транзитивних атрибутів
-- автора (вони живуть у "User" — там і мають жити)
ALTER TABLE "VideoDenormalized" DROP COLUMN category_and_subcategory;
ALTER TABLE "VideoDenormalized" DROP COLUMN author_username;
ALTER TABLE "VideoDenormalized" DROP COLUMN author_email;
ALTER TABLE "VideoDenormalized" DROP COLUMN tags;

-- 2d. RENAME — таблиця здорова
ALTER TABLE "VideoDenormalized" RENAME TO "VideoFixed";

SELECT * FROM "VideoFixed";

-- ============================================
-- ЛІКУВАННЯ КРОК 3 — НАПОВНЕННЯ M:N
-- 19 тегів у довідник; зв'язки через CROSS JOIN + WHERE —
-- усі правильні пари одним запитом, без ручного перебору.
-- ON CONFLICT DO NOTHING — скрипт ідемпотентний: повторний
-- прогін не падає і не створює дублів.
-- ============================================

INSERT INTO "Tag" (name) VALUES
    ('postgresql'), ('database'), ('tutorial'), ('beginners'),
    ('gaming'), ('eldenring'), ('rpg'), ('bossfight'),
    ('cooking'), ('pasta'), ('italian'), ('recipe'),
    ('travel'), ('tokyo'), ('japan'), ('nightwalk'),
    ('music'), ('guitar'), ('cover')
ON CONFLICT (name) DO NOTHING;

INSERT INTO "VideoTag" (video_id, tag_id)
SELECT v.id, t.id
FROM "Video" v
CROSS JOIN "Tag" t
WHERE (v.title = 'PostgreSQL Tutorial for Beginners'
       AND t.name IN ('postgresql', 'database', 'tutorial', 'beginners'))
   OR (v.title = 'Elden Ring — Final Boss Fight'
       AND t.name IN ('gaming', 'eldenring', 'rpg', 'bossfight'))
   OR (v.title = 'How to Make Perfect Pasta Carbonara'
       AND t.name IN ('cooking', 'pasta', 'italian', 'recipe'))
   OR (v.title = 'Exploring Tokyo — Shibuya at Night'
       AND t.name IN ('travel', 'tokyo', 'japan', 'nightwalk'))
   OR (v.title = 'Acoustic Guitar Cover — Wonderwall'
       AND t.name IN ('music', 'guitar', 'cover'))
ON CONFLICT DO NOTHING;

-- Перевірка: 19 зв'язків
SELECT COUNT(*) AS links FROM "VideoTag";

-- ============================================
-- ВЕРИФІКАЦІЯ — ТОЙ САМИЙ ІНФО-КОНТЕНТ ЧЕРЕЗ JOIN
-- Дані не втрачені — переупаковані.
-- ============================================

-- 1. Відео з тегами: чесний JOIN замість LIKE-хака
SELECT v.title, t.name AS tag
FROM "Video" v
INNER JOIN "VideoTag" vt ON v.id = vt.video_id
INNER JOIN "Tag" t ON vt.tag_id = t.id
ORDER BY v.title, t.name;

-- 2. Атомарні категорія/підкатегорія — без розрізання рядків
SELECT title, category, subcategory
FROM "VideoFixed"
ORDER BY category, subcategory;

-- 3. Email автора — з першоджерела (User), в одному місці
SELECT v.title, u.username, u.email
FROM "VideoFixed" v
JOIN "User" u ON u.id = v.author_id;

-- 4. Топ тегів — тепер чесний COUNT по junction
SELECT t.name, COUNT(vt.video_id) AS video_count
FROM "Tag" t
LEFT JOIN "VideoTag" vt ON vt.tag_id = t.id
GROUP BY t.name
ORDER BY video_count DESC, t.name;

-- ============================================
-- ПРИБИРАННЯ ПРИКЛАДУ
-- Демонстрація завершена — схема знову чиста:
-- 5 таблиць Lab 2 + Tag/VideoTag (легітимне розширення).
-- ============================================

DROP TABLE "VideoFixed";
