# upcomingEpisodes by @XxMariavxX

## ❇️ Create table

*Мета*: створити таблицю `upcoming_episodes` для зберігання майбутніх епізодів та індекс для сортування за датою виходу.
*Очікуваний результат*: створено таблицю з зовнішнім ключем на `animes`, складеним первинним ключем.
*Результат*: успішне виконання запитів `CREATE TABLE` та `CREATE INDEX`.

```SQL
CREATE TABLE IF NOT EXISTS public.upcoming_episodes(
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  PRIMARY KEY(anime_id, episode_name)
);

CREATE INDEX IF NOT EXISTS idx_upcoming_episode_date ON public.upcoming_episodes(episode_date ASC);
```

## 🗑 Drop table

*Мета*: видалити таблицю `upcoming_episodes` та всі її записи.
*Очікуваний результат*: таблиця `upcoming_episodes` видалена, якщо вона існує.
*Результат*: успішне виконання запиту `DROP TABLE`.

```SQL
BEGIN;
  DROP TABLE IF EXISTS public.upcoming_episodes;
COMMIT;
```


## ✨ Insert queries

### All colums
*Мета*: додати новий епізод з усіма полями.
*Очікуваний результат*: новий епізод буде доданий до таблиці `upcoming_episodes` з усіма вказаними даними.
*Результат*: успішне виконання запиту `INSERT` та додавання нового епізоду до таблиці.

```SQL
INSERT INTO public.upcoming_episodes(anime_id, episode_name, episode_date) VALUES
    ('018f3a5e-7a1b-7123-8abc-100000000001', 'Серія 13: Новий контракт', now() + INTERVAL '2 days'),
    ('018f3a5e-7a1b-7123-8abc-200000000002', 'Серія 14: Тіньовий монарх', now() + INTERVAL '5 days'),
    ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 29: Шлях на північ', now() + INTERVAL '7 days');
```

### Mandatory only colums
*Мета*: додати новий епізод для аніме з ID `018f3a5e-7a1b-7123-8abc-100000000001`, вказавши лише обов'язкові поля.
*Очікуваний результат*: новий епізод буде доданий до таблиці `upcoming_episodes` з автоматичною датою виходу, яка буде встановлена на поточний час.
*Результат*: успішне виконання запиту `INSERT` та додавання нового епізоду до таблиці.

```SQL
INSERT INTO public.upcoming_episodes(anime_id, episode_name) VALUES
    ('018f3a5e-7a1b-7123-8abc-100000000001', 'Спецепізод: Інтерв''ю з автором'),
    ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 30: Випробування мага', now() + INTERVAL '14 days'),
    ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 31: Зелений ліс', now() + INTERVAL '21 days');
```

### With returning part (`RETURNING`, optional)
*Мета*: додати новий епізод та отримати створені дані.
*Очікуваний результат*: новий епізод буде доданий до таблиці `upcoming_episodes`, а також будуть повернуті дані про цей епізод.
*Результат*: успішне виконання запиту `INSERT` з частиною `RETURNING`.

```SQL
INSERT INTO public.upcoming_episodes(anime_id, episode_name, episode_date) VALUES
    ('018f3a5e-7a1b-7123-8abc-200000000002', 'Серія 15: Подвійні врайта', now() + INTERVAL '12 days')
    ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 30: Випробування мага', now() + INTERVAL '14 days'),
    ('018f3a5e-7a1b-7123-8abc-300000000003', 'Серія 31: Зелений ліс', now() + INTERVAL '21 days')
RETURNING anime_id, episode_name, episode_date;
```

### Some interesting examples

*Мета*: додавання нових епізодів для конкретного аніме з використанням підзапиту для отримання `anime_id`.
*Очікуваний результат*: новий епізод буде доданий, якщо в таблиці `animes` існує доступне аніме зі slug `solo-leveling-season-2`; у поточних тестових даних такий slug відсутній, тому буде вставлено 0 рядків.
*Результат*: запит `INSERT ... SELECT` синтаксично коректний, але за поточними тестовими даними не додає жодного епізоду.

```SQL
INSERT INTO public.upcoming_episodes(anime_id, episode_name, episode_date)
SELECT
    anime_id, 'Серія 16: Битва у підземеллі', now() + INTERVAL '19 days'
FROM public.animes
WHERE
    slug = 'solo-leveling-season-2' AND
    available = TRUE;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
*Мета*: отримати всі записи з таблиці `upcoming_episodes`.
*Очікуваний результат*: всі записи з таблиці `upcoming_episodes` будуть повернуті.
*Результат*: успішне виконання запиту `SELECT` та повернення всіх записів.

```SQL
SELECT * FROM public.upcoming_episodes;
```

### Select public only info (no `WHERE`, specified fields)
*Мета*: отримати лише публічну інформацію про майбутні епізоди, включаючи назву епізоду та дату виходу.
*Очікуваний результат*: повертаються лише назви епізодів та дати виходу з таблиці `upcoming_episodes`.
*Результат*: успішне виконання запиту `SELECT` та повернення лише зазначених полів.

```SQL
SELECT episode_name, episode_date 
FROM public.upcoming_episodes;
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
FROM public.upcoming_episodes
WHERE
    anime_id = '018f3a5e-7a1b-7123-8abc-200000000002' AND
    episode_date >= now()
ORDER BY episode_date;
```

### Some interesting examples (optional)

- [x] ORDER BY
- [x] LIMIT
- [x] JOIN

*Мета*: отримати список майбутніх епізодів з інформацією про аніме, відсортованих за датою виходу, обмежених до 5 записів.
*Очікуваний результат*: повертається список майбутніх епізодів з інформацією про аніме, відсортованих за датою виходу, обмежених до 5 записів та пропустивши перші 0 записів.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `ORDER BY`, `LIMIT` та `OFFSET`.

```SQL
SELECT 
  a.title_ua,
  a.slug,
  a.cover_url,
  ue.episode_name,
  ue.episode_date
FROM public.upcoming_episodes ue
INNER JOIN public.animes a ON
    a.anime_id = ue.anime_id
WHERE
    ue.episode_date >= now()
ORDER BY ue.episode_date ASC
LIMIT 5;
```

*Це OLAP*.
*Мета*: отримати кількість майбутніх епізодів для кожного аніме, відсортованих за кількістю епізодів.
*Очікуваний результат*: повертається список аніме з кількістю майбутніх епізодів, відсортованих за кількістю епізодів.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `GROUP BY` та `ORDER BY`.

```SQL
SELECT 
    a.title_ua,
    COUNT(ue.episode_name) AS total_upcoming
FROM public.upcoming_episodes ue
INNER JOIN public.animes a ON
    a.anime_id = ue.anime_id
GROUP BY a.title_ua
ORDER BY total_upcoming;
```

## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: оновити дату виходу конкретного епізоду для аніме з ID `018f3a5e-7a1b-7123-8abc-100000000001`.
*Очікуваний результат*: дата виходу епізоду "Серія 13: Новий контракт" буде оновлена на 4 дні від поточного часу.
*Результат*: успішне виконання запиту `UPDATE` та оновлення дати виходу епізоду.

```SQL
UPDATE public.upcoming_episodes
SET
    episode_date = now() + INTERVAL '4 days'
WHERE
    anime_id = '018f3a5e-7a1b-7123-8abc-100000000001' AND
    episode_name = 'Серія 13: Новий контракт';
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: оновити назву конкретного епізоду для аніме з ID `018f3a5e-7a1b-7123-8abc-300000000003` і повернути інформацію про оновлений епізод.
*Очікуваний результат*: назва епізоду "Серія 29: Шлях на північ" буде оновлена на "Серія 29: Початок нової арки", і буде повернуто інформацію про оновлений епізод.
*Результат*: успішне виконання запиту `UPDATE` та повернення інформації про оновлений епізод.

```SQL
UPDATE public.upcoming_episodes
SET
    episode_name = 'Серія 29: Початок нової арки'
WHERE
    anime_id = '018f3a5e-7a1b-7123-8abc-300000000003' AND
    episode_name = 'Серія 29: Шлях на північ'
RETURNING anime_id, episode_name, episode_date;
```

## ⛔ Delete queries

### Clear table (no `WHERE`)
*Мета*: очистити таблицю `upcoming_episodes` від всіх записів.
*Очікуваний результат*: таблиця `upcoming_episodes` буде порожньою.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM public.upcoming_episodes;
```

### Delete with filter (`WHERE`)
*Мета*: видалити всі епізоди, дата виходу яких менша за поточний час.
*Очікуваний результат*: всі епізоди з датою виходу менше за поточний час будуть видалені з таблиці `upcoming_episodes`.
*Результат*: успішне виконання запиту `DELETE` та видалення відповідних записів.

```SQL
DELETE FROM public.upcoming_episodes
WHERE episode_date < now();
```

### Delete and return (`WHERE`, `RETURNING`)
*Мета*: видалити конкретний епізод і повернути інформацію про видалений епізод.
*Очікуваний результат*: епізод "Спецепізод: Інтерв'ю з автором" буде видалений з таблиці `upcoming_episodes`, і буде повернуто інформацію про видалений епізод.
*Результат*: успішне виконання запиту `DELETE` та повернення інформації про видалений епізод.

```SQL
DELETE FROM public.upcoming_episodes
WHERE
    anime_id = '018f3a5e-7a1b-7123-8abc-100000000001' AND
    episode_name = 'Спецепізод: Інтерв\'ю з автором'
RETURNING anime_id, episode_name, episode_date;
```
