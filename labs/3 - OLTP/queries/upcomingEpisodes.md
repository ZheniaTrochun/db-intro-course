# upcomingEpisodes by @XxMariavxX

## ❇️ Create table
Мета, очікуваний результат, чи успішно виконано

```SQL
CREATE TABLE upcoming_episodes(
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  PRIMARY KEY(anime_id, episode_name)
);

CREATE INDEX idx_upcoming_episode_date ON upcoming_episodes(episode_date ASC);
```


## 🗑 Drop table

```SQL
BEGIN;
DROP TABLE IF EXISTS upcoming_episodes CASCADE;
COMMIT;
```


## ✨ Insert queries

### IDs

- ``
- ``
- ``

### All colums
Мета, очікуваний результат, чи успішно виконано

```SQL
INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date)
VALUES
(
  '018f3a5e-7a1b-7123-8abc-100000000001',
  'Серія 13: Новий контракт',
  now() + INTERVAL '2 days'
),
(
  '018f3a5e-7a1b-7123-8abc-200000000002',
  'Серія 14: Тіньовий монарх',
  now() + INTERVAL '5 days'
),
(
  '018f3a5e-7a1b-7123-8abc-300000000003',
  'Серія 29: Шлях на північ',
  now() + INTERVAL '7 days'
);
```

### Mandatory only colums
Мета, очікуваний результат, чи успішно виконано

```SQL
INSERT INTO upcoming_episodes(anime_id, episode_name)
VALUES ('018f3a5e-7a1b-7123-8abc-100000000001', 'Спецепізод: Інтерв''ю з автором');
```

### With returning part (`RETURNING`, optional)
Мета, очікуваний результат, чи успішно виконано

```SQL
INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date)
VALUES (
  '018f3a5e-7a1b-7123-8abc-200000000002',
  'Серія 15: Подвійні врайта',
  now() + INTERVAL '12 days'
)
RETURNING anime_id, episode_name, episode_date;
```

### Some interesting examples (optional)
*Мета*: заповнення таблиці даними для подальшого використання в запитах `SELECT`, `UPDATE`, `DELETE` та інших.
*Очікуваний результат*: таблиця `upcoming_episodes` заповнена даними, які можна використовувати для тестування запитів.
*Результат*: успішне виконання запитів `INSERT` та заповнення таблиці даними.

```SQL
INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date)
VALUES 
  ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 30: Випробування мага', now() + INTERVAL '14 days'),
  ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 31: Зелений ліс', now() + INTERVAL '21 days');
```

*Мета*: додавання нових епізодів для конкретного аніме з використанням підзапиту для отримання `anime_id`.
*Очікуваний результат*: нові епізоди додані для аніме
*Результат*: успішне виконання запиту `INSERT` з використанням підзапиту.

```SQL
INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date)
SELECT anime_id, 'Серія 16: Битва у підземеллі', now() + INTERVAL '19 days'
FROM animes
WHERE slug = 'solo-leveling-season-2' 
  AND available = TRUE;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
*Мета*: отримати всі записи з таблиці `upcoming_episodes`.
*Очікуваний результат*: всі записи з таблиці `upcoming_episodes` будуть повернуті.
*Результат*: успішне виконання запиту `SELECT` та повернення всіх записів.

```SQL
SELECT * FROM upcoming_episodes;
```

### Select public only info (no `WHERE`, specified fields)
*Мета*: отримати лише публічну інформацію про майбутні епізоди, включаючи назву епізоду та дату виходу.
*Очікуваний результат*: повертаються лише назви епізодів та дати виходу з таблиці `upcoming_episodes`.
*Результат*: успішне виконання запиту `SELECT` та повернення лише зазначених полів.

```SQL
SELECT episode_name, episode_date 
FROM upcoming_episodes;
```

### API production example (like in `GET /api/anime/:id/comments`, `GET /api/user` etc)
*Мета*: отримати список майбутніх епізодів для конкретного аніме через API.
*Очікуваний результат*: повертається список майбутніх епізодів для аніме з ID `018f3a5e-7a1b-7123-8abc-200000000002`.
*Результат*: успішне виконання запиту `GET` до точки входу `upcoming-episodes`.

`GET /api/v1/animes/018f3a5e-7a1b-7123-8abc-200000000002/upcoming-episodes`

```SQL
SELECT 
  episode_name, 
  episode_date 
FROM upcoming_episodes
WHERE anime_id = '018f3a5e-7a1b-7123-8abc-200000000002'
  AND episode_date >= now()
ORDER BY episode_date;
```

### Some interesting examples (optional)

- [x] ORDER BY
- [x] LIMIT
- [x] OFFSET
- [x] JOIN

*Мета*: отримати список майбутніх епізодів з інформацією про аніме, відсортованих за датою виходу, обмежених до 5 записів та пропустивши перші 0 записів.
*Очікуваний результат*: повертається список майбутніх епізодів з інформацією про аніме, відсортованих за датою виходу, обмежених до 5 записів та пропустивши перші 0 записів.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `ORDER BY`, `LIMIT` та `OFFSET`.

```SQL
SELECT 
  a.title_ua,
  a.slug,
  a.cover_url,
  ue.episode_name,
  ue.episode_date
FROM upcoming_episodes ue
JOIN animes a ON a.anime_id = ue.anime_id
WHERE ue.episode_date >= now()
ORDER BY ue.episode_date ASC
LIMIT 5 OFFSET 0;
```

*Мета*: отримати список майбутніх епізодів для аніме з назвою, що містить слово "Solo", відсортованих за датою виходу.
*Очікуваний результат*: повертається список майбутніх епізодів для аніме з назвою, що містить слово "Solo", відсортованих за датою виходу.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `WHERE` та `ORDER BY`.

```SQL
SELECT 
  a.title_ua,
  COUNT(ue.episode_name) AS total_upcoming
FROM upcoming_episodes ue
JOIN animes a ON a.anime_id = ue.anime_id
GROUP BY a.title_ua
ORDER BY total_upcoming;
```


## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: оновити дату виходу конкретного епізоду для аніме з ID `018f3a5e-7a1b-7123-8abc-100000000001`.
*Очікуваний результат*: дата виходу епізоду "Серія 13: Новий контракт" буде оновлена на 4 дні від поточного часу.
*Результат*: успішне виконання запиту `UPDATE` та оновлення дати виходу епізоду.

```SQL
UPDATE upcoming_episodes
SET episode_date = now() + INTERVAL '4 days'
WHERE anime_id = '018f3a5e-7a1b-7123-8abc-100000000001'
  AND episode_name = 'Серія 13: Новий контракт';
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: оновити назву конкретного епізоду для аніме з ID `018f3a5e-7a1b-7123-8abc-300000000003` і повернути інформацію про оновлений епізод.
*Очікуваний результат*: назва епізоду "Серія 29: Шлях на північ" буде оновлена на "Серія 29: Початок нової арки", і буде повернуто інформацію про оновлений епізод.
*Результат*: успішне виконання запиту `UPDATE` та повернення інформації про оновлений епізод.

```SQL
UPDATE upcoming_episodes
SET episode_name = 'Серія 29: Початок нової арки'
WHERE anime_id = '018f3a5e-7a1b-7123-8abc-300000000003'
  AND episode_name = 'Серія 29: Шлях на північ'
RETURNING anime_id, episode_name, episode_date;
```

### Some interesting examples (optional)

Мета, очікуваний результат, чи успішно виконано

```SQL
```

Мета, очікуваний результат, чи успішно виконано

```SQL
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Delete with filter (`WHERE`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Delete and return (`WHERE`, `RETURNING`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Some interesting examples (optional)

Мета, очікуваний результат, чи успішно виконано

```SQL
```

Мета, очікуваний результат, чи успішно виконано

```SQL
```
