# animes by @XxMariavxX

## ❇️ Create table
Мета, очікуваний результат, чи успішно виконано
*Мета*: Створити переліки (ENUM) та таблицю animes з потрібними полями та обмеженнями, а також індекс для швидкого пошуку за полем available
*Очікуваний результат*: Створено 3 типи ENUM, таблицю animes та 1 індекс.

*Чи успішно виконано*: Так, запит виконано успішно.


```SQL
CREATE TYPE IF NOT EXISTS public.anime_format_enum AS ENUM('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE IF NOT EXISTS public.anime_status_enum AS ENUM('upcoming', 'ongoing', 'cancelled', 'finished');
CREATE TYPE IF NOT EXISTS public.mpaa_rating_enum AS ENUM('g', 'pg', 'pg13', 'r', 'nc17');

CREATE TABLE IF NOT EXISTS public.animes(
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

CREATE INDEX IF NOT EXISTS idx_anime_available ON public.animes(available);
```

## 🗑 Drop table
*Мета*: Запит для повного видалення таблиці та її даних
*Очікуваний результат*: Таблиця animes та її дані видалені.
*Чи успішно виконано*: Так, запит виконано успішно.
  
```SQL
BEGIN;
  DROP TABLE IF EXISTS public.animes CASCADE;
  DROP TYPE IF EXISTS public.anime_format_enum, public.anime_status_enum, public.mpaa_rating_enum;
COMMIT;
```


## ✨ Insert queries

### IDs

- `34343434-3434-3434-3434-343434343434`
- `40404040-4040-4040-4040-404040404040`
- `f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce`

*Мета*: Вставити нові записи в таблицю animes з використанням автоматично згенерованих ID.
*Очікуваний результат*: Нові записи вставлені в таблицю animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
INSERT INTO public.animes(
  slug, title_ua, title_en, title_original, year_released, episodes_count, age_restriction, anime_status
) VALUES 
    ('naruto', 'Наруто', 'Naruto', 'ナルト', 2002, 220, 'pg13', 'finished'),
    ('one-piece', 'Ван Піс', 'One Piece', 'ONE PIECE', 1999, 1000, 'pg13', 'ongoing'),
    ('demon-slayer', 'Вбивця демонів', 'Demon Slayer', 'Demon Slayer', 2019, 26, 'pg13', 'finished');
 ```

### All colums
*Мета*: Вставити нові записи в таблицю animes з усіма полями.
*Очікуваний результат*: Нові записи вставлені в таблицю animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
INSERT INTO public.animes(
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

INSERT INTO public.animes(
  anime_id, slug, title_ua, title_en, title_original, anime_description,
  cover_url, production_studio, year_released, episodes_count, age_restriction,
  anime_status, anime_format, available
) VALUES
(
  '018f3a5e-7a1b-7123-8abc-100000000001',
  'chainsaw-man', 'Людина-бензопила', 'Chainsaw Man', 'Chainsaw Man',
  'Юнак Денджі живе у злиднях і полює на демонів, щоб виплатити борги батька.',
  'https://example.com/csm.jpg', 'MAPPA', 2022, 12, 'r', 'ongoing', 'tv', TRUE
),
(
  '018f3a5e-7a1b-7123-8abc-200000000002',
  'solo-leveling', 'Підняття рівня в поодинці', 'Solo Leveling', 'Ore dake Level Up na Ken',
  'Найслабший мисливець Сон Джин-У отримує унікальну можливість піднімати свій рівень у системі.',
  'https://example.com/solo.jpg', 'A-1 Pictures', 2024, 12, 'r', 'ongoing', 'tv', TRUE
),
(
  '018f3a5e-7a1b-7123-8abc-300000000003',
  'frieren', 'Фрірен: Після завершення подорожі', 'Frieren: Beyond Journey''s End', 'Sousou no Frieren',
  'Ельфійська магічка Фрірен переосмислює плин часу та цінність людського життя після перемоги над Королем Демонів.',
  'https://example.com/frieren.jpg', 'Madhouse', 2023, 28, 'pg13', 'ongoing', 'tv', TRUE
);
```

### Mandatory only colums

*Мета*: Вставити новий запис в таблицю animes, використовуючи лише обов'язкові поля.
*Очікуваний результат*: Новий запис вставлено в таблицю animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
INSERT INTO public.animes(slug)
VALUES ('digimon-beatbreak');
```

### Select by slug

*Мета*: Вибрати ідентифікатор, slug та назви аніме з певним slug.
*Очікуваний результат*: Запис із таблиці `animes` зі slug = 'attack-on-titan' і полями `anime_id`, `slug`, `title_ua`, `title_en`.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT anime_id, slug, title_ua, title_en
FROM public.animes 
WHERE slug = 'attack-on-titan';
```

### Some interesting examples (optional)

*Це OLAP*.
*Мета*: Порахувати доступні аніме за кожним статусом.
*Очікуваний результат*: Кількість доступних аніме для кожного непорожнього значення `anime_status`.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT 
    anime_status,
    COUNT(*) AS total_count_animes
FROM public.animes
WHERE 
    available = TRUE AND
    anime_status IS NOT NULL
GROUP BY anime_status;
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
FROM public.animes 
WHERE 
    available = TRUE AND 
    year_released = EXTRACT(YEAR FROM now()::date)
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
FROM public.animes 
WHERE 
    available = TRUE AND 
    (
        cover_url IS NULL OR
        cover_url = '' OR
        anime_description = ''
    );
```

## 📨 Select queries

### Select all entries (no `WHERE`, all fields)

*Мета*: Вибрати всі записи з таблиці animes.
*Очікуваний результат*: Всі записи з таблиці animes.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT * FROM public.animes;
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
FROM public.animes;
```

### API production example (like in `GET /api/anime/:id/comments`, `GET /api/user` etc)

*Мета*: Вибрати публічну інформацію про аніме з певним slug.
*Очікуваний результат*: Записи з таблиці animes, що містять лише публічну інформацію про аніме з slug = 'attack-on-titan'.
*Чи успішно виконано*: Так, запит виконано успішно.

`GET /api/v1/animes/attack-on-titan`
```SQL
SELECT 
  anime_id, slug, 
  title_ua, title_en, 
  title_original, anime_description, 
  cover_url, production_studio, 
  mal_id, anilist_id, 
  hikka_id, imdb_id, 
  year_released, avg_episode_duration, 
  episodes_count, age_restriction, 
  anime_status, anime_format
FROM public.animes
WHERE
    slug = 'attack-on-titan' AND
    available = TRUE;
```

### Some interesting examples (optional)

- [x] ORDER BY
- [x] LIMIT
- [x] OFFSET

*Мета*: Вибрати останні 18 доступних аніме, відсортованих за зменшенням anime_id.
*Очікуваний результат*: 18 останніх доступних аніме, відсортованих за зменшенням anime_id.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
SELECT 
  anime_id, 
  slug, 
  title_ua, 
  year_released,
  cover_url, 
  episodes_count, 
  available 
FROM public.animes 
WHERE available = TRUE
ORDER BY anime_id DESC 
LIMIT 18;
```

## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: Оновити опис та статус аніме з певним slug.
*Очікуваний результат*: Опис та статус аніме з slug = 'attack-on-titan' оновлено.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
UPDATE public.animes 
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
UPDATE public.animes 
SET available = FALSE 
WHERE age_restriction = 'pg13'
RETURNING anime_id, slug, age_restriction, available;
```

*Мета*: Зробити доступними всі аніме, які мають заповнені назви та зараз недоступні, і повернути оновлені записи.
*Очікуваний результат*: Для відповідних записів поле `available` змінено на `TRUE`, а оновлені ідентифікатори, slug, вікові обмеження та статус доступності повернуті.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
UPDATE public.animes 
SET available = TRUE
WHERE
    title_ua <> '' AND
    title_en <> '' AND
    title_original <> ''
RETURNING anime_id, slug, age_restriction, available;
```

### Some interesting examples (optional)

*Мета*: Оновити статус аніме для всіх аніме з поточного року, які мають статус 'ongoing' та більше 0 епізодів, на 'finished'.
*Очікуваний результат*: Статус аніме для всіх аніме з поточного року, які мають статус 'ongoing' та більше 0 епізодів, оновлено на 'finished'.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
UPDATE public.animes 
SET anime_status = 'finished'
WHERE 
    year_released = extract(YEAR FROM now()::date) AND
    anime_status = 'ongoing' AND
    episodes_count > 0;
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
*Мета*: Видалити недоступні аніме без української назви.
*Очікуваний результат*: Видалені записи з `available = FALSE`, у яких `title_ua` має значення `NULL` або порожній рядок.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
DELETE FROM public.animes 
WHERE
    (title_ua IS NULL OR title_ua = '') AND
    available = FALSE;
```

### Delete and return (`WHERE`, `RETURNING`)
*Мета*: Видалити завершені аніме, які мають опис або не мають виробничої студії, та повернути їхні ідентифікатори й назви.
*Очікуваний результат*: Відповідні записи видалені, а поля `anime_id`, `slug` і `title_ua` повернуті.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
DELETE FROM public.animes 
WHERE
    anime_status = 'finished' AND 
    (
        anime_description <> '' OR
        production_studio IS NULL
    ) 
RETURNING anime_id, slug, title_ua;
```

### Some interesting examples (optional)

*Мета*: Видалити завершені аніме, для яких не існує жодного епізоду, і повернути видалені записи.
*Очікуваний результат*: Видалені завершені аніме без пов'язаних записів у `episodes`, а їхні ідентифікатори та назви повернуті.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
DELETE FROM public.animes anm 
WHERE 
    anm.anime_status = 'finished' AND
    NOT EXISTS (
        SELECT 1
        FROM episodes ep 
        WHERE ep.anime_id = anm.anime_id
    ) 
RETURNING anm.anime_id, anm.slug, anm.title_ua;
```

*Мета*: Видалити майбутні аніме, дата випуску яких відстає від поточного року більш ніж на три роки.
*Очікуваний результат*: Видалені аніме зі статусом `upcoming` та роком випуску меншим за поточний рік мінус три; їхні ідентифікатори, slug і рік повернуті.
*Чи успішно виконано*: Так, запит виконано успішно.

```SQL
DELETE FROM public.animes 
WHERE
    anime_status = 'upcoming' AND
    year_released < extract(YEAR FROM now()::date) - 3
RETURNING anime_id, slug, year_released;
```
