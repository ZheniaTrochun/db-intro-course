# animes by @XxMariavxX

## ❇️ Create table
Мета, очікуваний результат, чи успішно виконано
*Мета*: Створити переліки (ENUM) та таблицю animes з потрібними полями та обмеженнями, а також індекс для швидкого пошуку за полем available
*Очікуваний результат*: Створено 3 типи ENUM, таблицю animes та 1 індекс.

*Чи успішно виконано*: Так, запит виконано успішно.


```SQL
CREATE TYPE anime_format_enum AS ENUM('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE anime_status_enum AS ENUM('upcoming', 'ongoing', 'cancelled', 'finished');
CREATE TYPE mpaa_rating_enum AS ENUM('g', 'pg', 'pg13', 'r', 'nc17');

CREATE TABLE animes(
  anime_id UUID PRIMARY KEY DEFAULT uuidv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT NOT NULL DEFAULT '',
  title_en TEXT NOT NULL DEFAULT '',
  title_original TEXT NOT NULL DEFAULT '',
  anime_description TEXT NOT NULL DEFAULT '',
  cover_url TEXT,
  production_studio TEXT,
  mal_id BIGINT,
  anilist_id BIGINT,
  hikka_id TEXT,
  imdb_id TEXT,
  year_released SMALLINT CHECK(year_released >= 1900),
  avg_episode_duration SMALLINT NOT NULL DEFAULT 0 CHECK(avg_episode_duration >= 0),
  episodes_count SMALLINT NOT NULL DEFAULT 0 CHECK(episodes_count >= 0),
  age_restriction mpaa_rating_enum,
  anime_status anime_status_enum,
  anime_format anime_format_enum NOT NULL DEFAULT 'tv',
  available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_anime_available ON animes(available);
```


## 🗑 Drop table
*Мета*: Запит для повного видалення таблиці та її даних
*Очікуваний результат*: Таблиця animes та її дані видалені.
*Чи успішно виконано*: Так, запит виконано успішно.
  
```SQL
BEGIN;

  DROP TABLE IF EXISTS animes CASCADE;
  DROP TYPE IF EXISTS anime_format_enum, anime_status_enum, mpaa_rating_enum;

COMMIT;
```


## ✨ Insert queries

### IDs
*Мета*: Вставити нові записи в таблицю animes з використанням автоматично згенерованих ID.
*Очікуваний результат*: Нові записи вставлені в таблицю animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
INSERT INTO animes (
  slug, title_ua, title_en, title_original, year_released, episodes_count, age_restriction, anime_status
) VALUES 
(
  'naruto', 'Наруто', 'Naruto', 'ナルト', 
  2002, 220, 'pg13', 'finished'
),
(
  'one-piece', 'Ван Піс', 'One Piece', 'ONE PIECE', 
  1999, 1000, 'pg13', 'ongoing'
),
(
  'demon-slayer', 'Вбивця демонів', 'Demon Slayer', 'Demon Slayer', 2019, 26, 'pg13', 'finished'
);
 ```

### All colums
*Мета*: Вставити нові записи в таблицю animes з усіма полями.
*Очікуваний результат*: Нові записи вставлені в таблицю animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
INSERT INTO animes (
  anime_id, slug, title_ua, title_en, title_original, anime_description, 
  cover_url, production_studio, mal_id, anilist_id, hikka_id, imdb_id, 
  year_released, avg_episode_duration, episodes_count, age_restriction, 
  anime_status, anime_format, available
) VALUES (
  '34343434-3434-3434-3434-343434343434',
  'attack-on-titan', 'Атака титанів', 'Attack on Titan', 'Shingeki no Kyojin', 
  'Оновлений опис аніме Attack on Titan', 
  'https://example.com/aot.jpg', 'WIT Studio', 16498, 16498, 
  'hikka_aot', 'tt2560140', 2013, 24, 25, 'r', 'ongoing', 'tv', TRUE
),
(
  '40404040-4040-4040-4040-404040404040',
  'my-hero-academia', 'Моя геройська академія', 'My Hero Academia', 'Boku no Hero Academia', 
  'У світі, де більшість людей мають надздібності, молодий хлопець без сил мріє стати героєм.', 
  'https://example.com/mha.jpg', 'Bones', 31964, 31964, 
  'hikka_mha', 'tt5626028', 2016, 24, 88, 'pg13', 'ongoing', 'tv', TRUE
),
(
  'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce',
  'jujutsu-kaisen', 'Прокляття Джудзюцу', 'Jujutsu Kaisen', 'Jujutsu Kaisen', 
  'Учень старшої школи вступає до школи прокляттів, щоб боротися з небезпечними прокляттями.', 
  'https://example.com/jjk.jpg', 'MAPPA', 40748, 40748, 
  'hikka_jjk', 'tt11126994', 2020, 24, 24, 'pg13', 'ongoing', 'tv', TRUE
);
```

### Mandatory only colums

*Мета*: Вставити новий запис в таблицю animes, використовуючи лише обов'язкові поля.
*Очікуваний результат*: Новий запис вставлено в таблицю animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
INSERT INTO animes (slug) 
VALUES ('digimon-beatbreak');
```

### With returning part (`RETURNING`, optional)

*Мета*: Вибрати записи з таблиці animes з певним slug і повернути вказаний набір полів.
*Очікуваний результат*: Записи з таблиці animes з slug = 'attack-on-titan' і вказаними полями.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT * 
FROM animes 
WHERE slug = 'attack-on-titan' 
RETURNING anime_id, slug, title_ua, title_en; 
```

### Some interesting examples (optional)

*Мета*: Вибрати записи з таблиці animes з певним slug і повернути вказаний набір полів.
*Очікуваний результат*: Записи з таблиці animes з slug = 'attack-on-titan' і вказаними полями.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT 
  anime_status,
  COUNT(*) AS total_count_animes
FROM animes
WHERE available = TRUE 
  AND anime_status IS NOT NULL
GROUP BY anime_status
```

*Мета*: Знайти всі аніме, які були випущені у поточному році та доступні для перегляду.
*Очікуваний результат*: Записи з таблиці animes, де available = TRUE та year_released = поточний рік.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT 
  anime_id, 
  slug, 
  title_ua, 
  year_released, 
  cover_url, 
  episodes_count 
FROM animes 
WHERE available = TRUE 
  AND year_released = EXTRACT(YEAR FROM CURRENT_DATE)
ORDER BY year_released DESC;
```

*Мета*: Знайти всі аніме, у яких відсутні важливі публічні дані
*Очікуваний результат*: Записи з таблиці animes, де відсутні дані про обкладинку або опис.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT 
  anime_id, 
  slug, 
  title_ua, 
  cover_url, 
  anime_description 
FROM animes 
WHERE available = TRUE 
  AND (
    cover_url IS NULL 
    OR cover_url = '' 
    OR anime_description = ''
  );
```

## 📨 Select queries

### Select all entries (no `WHERE`, all fields)

*Мета*: Вибрати всі записи з таблиці animes.
*Очікуваний результат*: Всі записи з таблиці animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT * FROM animes;
```

### Select public only info (no `WHERE`, specified fields)

*Мета*: Вибрати публічну інформацію з таблиці animes.
*Очікуваний результат*: Записи з таблиці animes, що містять лише публічну інформацію.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT 
  anime_id,
  slug,
  title_ua, 
  title_en, 
  year_released, 
  episodes_count
FROM animes;
```

### API production example (like in `GET /api/anime/:id/comments`, `GET /api/user` etc)
*Мета*: Вибрати публічну інформацію про аніме з певним slug.
*Очікуваний результат*: Записи з таблиці animes, що містять лише публічну інформацію про аніме з slug = 'attack-on-titan'.
*Чи успішно виконано*: Так, запит виконано успішно.

`GET /api/v1/animes/attack-on-titan`
```SQL
SELECT 
  anime_id, 
  slug, 
  title_ua, 
  title_en, 
  title_original, 
  anime_description, 
  cover_url, 
  production_studio, 
  mal_id, 
  anilist_id, 
  hikka_id, 
  imdb_id, 
  year_released, 
  avg_episode_duration, 
  episodes_count, 
  age_restriction, 
  anime_status, 
  anime_format
FROM animes
WHERE slug = 'attack-on-titan' 
  AND available = TRUE;
```

### Some interesting examples (optional)

- [x] ORDER BY
- [x] LIMIT
- [x] OFFSET
- [ ] JOIN
- [x] GROUP BY

Мета, очікуваний результат, чи успішно виконано
*Мета*: Вибрати записи з таблиці animes, відсортовані за роком випуску у спадному порядку, і обмежені кількістю 5.
*Очікуваний результат*: Записи з таблиці animes, відсортовані за роком випуску у спадному порядку, і обмежені кількістю 5.
*Чи успішно виконано*: Так, запит виконано успішно.

<!-- цей запит цікавий, а якщо null у рядках? -->
```SQL
SELECT 
  anime_id, 
  slug, 
  title_ua, 
  year_released,
  cover_url, 
  episodes_count, 
  available 
FROM animes 
WHERE available = TRUE
ORDER BY anime_id DESC 
LIMIT 18 OFFSET 0;
```

## 🔄 Update queries

### Update some fields (`WHERE`)
Мета, очікуваний результат, чи успішно виконано
*Мета*: Оновити опис та статус аніме з певним slug.
*Очікуваний результат*: Опис та статус аніме з slug = 'attack-on-titan' оновлено.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
UPDATE animes 
SET
  anime_description = 'Після того, як його рідне місто було зруйноване, Ерен Єгер присягається очистити землю від титанів.',
  anime_status = 'finished'
WHERE slug = 'attack-on-titan';
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: Оновити поле available для всіх аніме з віковим обмеженням 'pg13' та повернути оновлені записи.
*Очікуваний результат*: Поле available для всіх аніме з віковим обмеженням 'pg13' оновлено на FALSE, і повернуто оновлені записи.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
UPDATE animes 
SET available = FALSE 
WHERE age_restriction = 'pg13'
RETURNING anime_id, slug, age_restriction, available;
```

```SQL
UPDATE animes 
SET available = TRUE
WHERE
  AND title_ua <> ''
  AND title_en <> '' 
  AND title_original <> ''
  AND available = FALSE
RETURNING anime_id, slug, age_restriction, available;
```

### Some interesting examples (optional)

*Мета*: Оновити статус аніме для всіх аніме з поточного року, які мають статус 'ongoing' та більше 0 епізодів, на 'finished'.
*Очікуваний результат*: Статус аніме для всіх аніме 
з поточного року, які мають статус 'upcoming' та більше 0 епізодів, оновлено на 'ongoing'.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
UPDATE animes 
SET anime_status = 'finished'
WHERE year_released = EXTRACT(YEAR FROM CURRENT_DATE)
  AND anime_status = 'ongoing'
  AND episodes_count > 0;
```

Мета, очікуваний результат, чи успішно виконано

```SQL
UPDATE animes anm
SET anime_status = 'finished'
WHERE EXISTS (
  SELECT
  FROM episodes ep
  WHERE ep.anime_id = anm.anime_id 
    AND ep.is_dubbed = TRUE 
    AND ep.episode_number = anm.episodes_count 
)
AND anm.anime_status = 'ongoing'
RETURNING anm.anime_id, anm.title_ua, anm.anime_status;
```


## ⛔ Delete queries

### Clear table (no `WHERE`)

*Мета*: Видалити всі записи з таблиці animes.
*Очікуваний результат*: Всі записи з таблиці animes видалені.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
DELETE FROM animes;
```

### Delete with filter (`WHERE`)
Мета, очікуваний результат, чи успішно виконано

```SQL
DELETE FROM animes 
WHERE (title_ua IS NULL OR title_ua = '') 
  AND available = FALSE;
```

### Delete and return (`WHERE`, `RETURNING`)
Мета, очікуваний результат, чи успішно виконано

```SQL
DELETE FROM animes 
WHERE anime_status = 'finished' 
  AND (anime_description <> '' 
      OR production_studio IS NULL) 
RETURNING anime_id, slug, title_ua;
```

### Some interesting examples (optional)

Мета, очікуваний результат, чи успішно виконано

```SQL
DELETE FROM animes anm 
WHERE anm.anime_status = 'finished' 
  AND NOT EXISTS (
    SELECT 1
    FROM episodes ep 
    WHERE ep.anime_id = anm.anime_id
  ) 
RETURNING anm.anime_id, anm.slug, anm.title_ua;
```

Мета, очікуваний результат, чи успішно виконано

```SQL
DELETE FROM animes 
WHERE anime_status = 'upcoming' 
  AND year_released < EXTRACT(YEAR FROM CURRENT_DATE) - 3 
RETURNING anm.anime_id, anm.slug, anm.year_released;
```
