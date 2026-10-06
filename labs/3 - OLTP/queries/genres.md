# genres by @XxMariavxX

## ❇️ Create table

*Мета*: створити ENUM `genre_type_enum`, таблицю `genres` зі зв'язком із `animes` та індекс для пошуку за типом жанру.
*Очікуваний результат*: створено тип `genre_type_enum`, таблицю `genres` з первинним ключем та зовнішнім ключем, а також індекс `idx_genre_type`.
*Результат*: успішне виконання запитів `CREATE TYPE`, `CREATE TABLE` та `CREATE INDEX`.

```SQL
CREATE TYPE genre_type_enum AS ENUM(
    'action','adventure',
    'avant_garde','award_winning',
    'boys_love','comedy',
    'drama','fantasy',
    'girls_love','gourmet',
    'horror','mystery',
    'romance','sci-fi',
    'slice_of_life',
    'sports','supernatural',
    'suspense','ecchi',
    'erotica','hentai',
    'adult_cast','anthropomorphic',
    'cgdct','childcare',
    'combat_sports','crossdressing',
    'delinquents','detective',
    'educational','gag_humor',
    'gore','harem',
    'high_stakes_game','historical',
    'idols_female','idols_male',
    'isekai','iyashikei',
    'love_polygon','love_status_quo',
    'fantasyal_sex_shift','mahou_shoujo',
    'martial_arts','mecha',
    'medical','military',
    'music','mythology',
    'organized_crime',
    'otaku_culture','parody',
    'performing_arts','pets',
    'psychological','racing',
    'reincarnation','reverse_harem',
    'samurai','school',
    'showbiz','space',
    'strategy_game','super_power',
    'survival','team_sports',
    'time_travel','urban_fantasy',
    'vampire','video_game',
    'villainess','visual_arts',
    'workplace','josei',
    'kids','seinen',
    'shoujo','shounen'
);

CREATE TABLE genres(
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  genre_type genre_type_enum NOT NULL,

  PRIMARY KEY(anime_id, genre_type)
);

CREATE INDEX idx_genre_type ON genres(genre_type);
```

## 🗑 Drop table
*Мета*: видалити таблицю `genres` та тип `genre_type_enum`, якщо вони існують.
*Очікуваний результат*: таблиця `genres` та тип `genre_type_enum`
будуть видалені з бази даних, якщо вони існують.
*Результат*: успішне виконання запиту `DROP TABLE` та `DROP TYPE`, якщо вони існували.

```SQL
BEGIN;
  DROP TABLE IF EXISTS genres CASCADE;
  DROP TYPE IF EXISTS genre_type_enum;
COMMIT;
```

## ✨ Insert queries

### All colums
*Мета*: додати нові жанри до таблиці `genres`.
*Очікуваний результат*: нові жанри будуть додані до таблиці `genres`.
*Результат*: успішне виконання запиту `INSERT` та додавання нових жанрів до таблиці.

```SQL
INSERT INTO genres(anime_id, genre_type)
VALUES 
(
  '34343434-3434-3434-3434-343434343434',
  'action'
),
(
  '34343434-3434-3434-3434-343434343434',
  'fantasy'
),
(
  '018f3a5e-7a1b-7123-8abc-100000000001',
  'action'
),
(
  '018f3a5e-7a1b-7123-8abc-100000000001',
  'supernatural'
),
(
  '018f3a5e-7a1b-7123-8abc-200000000002',
  'action'
),
(
  '018f3a5e-7a1b-7123-8abc-200000000002',
  'fantasy'
),
(
  '018f3a5e-7a1b-7123-8abc-200000000002',
  'urban_fantasy'
),
(
  '018f3a5e-7a1b-7123-8abc-100000000001',
  'gore'
),
(
  '018f3a5e-7a1b-7123-8abc-100000000001',
  'horror'
),
(
  '018f3a5e-7a1b-7123-8abc-300000000003',
  'fantasy'
),
(
  '018f3a5e-7a1b-7123-8abc-300000000003',
  'drama'
),
(
  'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce',
  'action'
),
(
  'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce',
  'supernatural'
),
(
  'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce',
  'school'
),
(
  '40404040-4040-4040-4040-404040404040',
  'action'
),
(
  '40404040-4040-4040-4040-404040404040',
  'super_power'
),
(
  '40404040-4040-4040-4040-404040404040',
  'school'
);

```

### With returning part (`RETURNING`, optional)
*Мета*: додати новий жанр та отримати повернені дані.
*Очікуваний результат*: новий жанр буде доданий до таблиці `genres`, а також будуть повернуті дані про цей жанр.
*Результат*: успішне виконання запиту `INSERT` з частиною `RETURNING`.

```SQL
INSERT INTO genres(anime_id, genre_type)
VALUES ('018f3a5e-7a1b-7123-8abc-300000000003', 'adventure')
RETURNING anime_id, genre_type;
```

## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
*Мета*: отримати всі записи з таблиці `genres`.
*Очікуваний результат*: всі записи з таблиці `genres` будуть повернуті.
*Результат*: успішне виконання запиту `SELECT` та повернення всіх записів.

```SQL
SELECT * FROM genres;
```

### Select public only info (no `WHERE`, specified fields)
*Мета*: отримати лише типи жанрів з таблиці `genres`.
*Очікуваний результат*: будуть повернуті лише типи жанрів.
*Результат*: успішне виконання запиту `SELECT` та повернення типів жанрів.

```SQL
SELECT genre_type 
FROM genres;
```

### API production example (like in `GET /api/anime/:id/comments`, `GET /api/user` etc)
*Мета*: отримати список жанрів для конкретного аніме через API.
*Очікуваний результат*: повертаються жанри аніме з ID `34343434-3434-3434-3434-343434343434`, відсортовані за назвою жанру.
*Результат*: успішне виконання запиту `SELECT` для точки входу `GET /api/v1/animes/:id/genres`.

`GET /api/v1/animes/:id/genres`

```SQL
SELECT genre_type 
FROM genres
WHERE anime_id = '34343434-3434-3434-3434-343434343434'
ORDER BY genre_type ASC;
```

### Some interesting examples (optional)

- [x] ORDER BY
- [x] LIMIT
- [x] OFFSET
- [x] JOIN

*Мета*: отримати список аніме з їх жанрами, відсортованих за назвою аніме, обмежених до 18 записів.
*Очікуваний результат*: повертається список аніме з їх жанрами, відсортованих за назвою аніме, обмежених до 18 записів.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `ORDER BY` та `LIMIT`.

```SQL
SELECT 
  a.title_ua,
  g.genre_type
FROM animes a
JOIN genres g ON a.anime_id = g.anime_id
WHERE a.available = TRUE
ORDER BY a.title_ua ASC
LIMIT 18 OFFSET 0;
```

## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: оновити тип жанру для певного аніме.
*Очікуваний результат*: тип жанру буде оновлений.
*Результат*: успішне виконання запиту `UPDATE`.

```SQL
UPDATE genres
SET genre_type = 'fantasy'
WHERE anime_id = '018f3a5e-7a1b-7123-8abc-100000000001'
  AND genre_type = 'supernatural';
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: оновити тип жанру для певного аніме та повернути оновлені значення.
*Очікуваний результат*: тип жанру буде оновлений, і будуть повернуті оновлені значення.
*Результат*: успішне виконання запиту `UPDATE` з частиною `RETURNING`.

```SQL
UPDATE genres
SET genre_type = 'shounen'
WHERE anime_id = '018f3a5e-7a1b-7123-8abc-200000000002'
  AND genre_type = 'action'
RETURNING anime_id, genre_type;
```

### Some interesting examples (optional)

*Мета*: оновити тип жанру для всіх аніме, випущених після 2020 року, та повернути оновлені значення.
*Очікуваний результат*: запит мав би оновити тип жанру для аніме, випущених після 2020 року, і повернути оновлені значення, але фактично завершиться помилкою через недійсне значення `fantasy`.
*Результат*: запит не виконується, оскільки значення `fantasy` відсутнє в ENUM `genre_type_enum`.

```SQL
UPDATE genres g
SET genre_type = 'fantasy'
FROM animes a
WHERE g.anime_id = a.anime_id
  AND g.genre_type = 'fantasy'
  AND a.year_released >= 2020
RETURNING g.anime_id, g.genre_type;
```

## ⛔ Delete queries

### Clear table (no `WHERE`)
*Мета*: видалити всі записи з таблиці `genres`.
*Очікуваний результат*: всі записи з таблиці `genres` будуть видалені.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM genres;
```

### Delete with filter (`WHERE`)
*Мета*: видалити конкретний жанр для певного аніме.
*Очікуваний результат*: конкретний жанр буде видалений для певного аніме.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM genres
WHERE anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce'
  AND genre_type = 'school';
```

### Delete and return (`WHERE`, `RETURNING`)
*Мета*: видалити конкретний жанр для певного аніме та повернути видалені значення.
*Очікуваний результат*: конкретний жанр буде видалений для певного аніме, і будуть повернуті видалені значення.
*Результат*: успішне виконання запиту `DELETE` з частиною `RETURNING`.

```SQL
DELETE FROM genres
WHERE anime_id = '018f3a5e-7a1b-7123-8abc-100000000001'
  AND genre_type = 'horror'
RETURNING anime_id, genre_type;
```