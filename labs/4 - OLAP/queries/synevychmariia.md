## OLAP Queries

## Рахує кількість аніме за статусом
Опис: Цей запит підраховує кількість аніме у базі даних за їхнім статусом (наприклад, "випущено", "у виробництві", "завершено" тощо). Він фільтрує лише ті записи, де аніме доступне (available = TRUE) та має визначений статус (anime_status IS NOT NULL). Результат групується за статусом аніме та повертає загальну кількість аніме для кожного статусу.

```SQL
SELECT 
    anime_status,
    count(*) AS total_count_animes
FROM public.animes
WHERE 
    available = TRUE 
    AND anime_status IS NOT NULL
GROUP BY anime_status;
```

## Рахує кількість аніме за студією
Опис: Цей запит підраховує кількість аніме у базі даних за студією виробництва. Він фільтрує лише ті записи, де студія виробництва визначена (production_studio IS NOT NULL). Результат групується за студією виробництва та повертає загальну кількість аніме для кожної студії.

```SQL
SELECT 
  production_studio,
  count(DISTINCT anime_id) AS total_animes,
  sum(episodes_count) AS total_episodes,
  round(avg(avg_episode_duration), 1) AS avg_duration
FROM public.animes
WHERE production_studio IS NOT NULL
GROUP BY production_studio
ORDER BY total_episodes DESC;
```

## Рахує кількість аніме за форматом
Опис: Цей запит підраховує кількість аніме у базі даних за їхнім форматом (наприклад, "TV", "OVA", "ONA" тощо). Результат групується за форматом аніме та повертає загальну кількість аніме для кожного формату.

```SQL
SELECT 
    anime_format,
    count(anime_id) AS total_titles,
    round(avg(episodes_count), 1) AS avg_episodes,
    max(episodes_count) AS max_episodes,
    min(episodes_count) AS min_episodes
FROM public.animes
GROUP BY anime_format;
```

------

## Рахує кількість аніме за жанром
Опис: Цей запит підраховує кількість аніме у базі даних за їхнім жанром. Він використовує `LEFT JOIN` для об'єднання таблиць `genres` та `animes`, щоб врахувати всі жанри, навіть якщо для деяких з них немає відповідних аніме. Результат групується за типом жанру та повертає загальну кількість аніме для кожного жанру, відсортовану за кількістю аніме у спадному порядку, а потім за типом жанру у спадному порядку.

```SQL
SELECT 
  genres.genre_type,
  count(animes.anime_id) AS anime_count
FROM public.genres
LEFT JOIN public.animes ON genres.anime_id = animes.anime_id
GROUP BY genres.genre_type
ORDER BY anime_count DESC, genres.genre_type DESC;
```

## Рахує кількість аніме за жанром, де кількість аніме більше 2
Опис: Цей запит підраховує кількість аніме у базі даних за їхнім жанром, але повертає лише ті жанри, де кількість аніме перевищує 2. Він групує результати за типом жанру та сортує їх за кількістю аніме у спадному порядку.

```SQL
SELECT 
    genre_type,
    count(anime_id) AS anime_count
FROM public.genres
GROUP BY genre_type
HAVING count(anime_id) > 2
ORDER BY anime_count DESC;
```

## Рахує кількість аніме за жанром, де кількість аніме більше 2
Опис: Цей запит підраховує кількість аніме у базі даних за їхнім жанром, але повертає лише ті жанри, де кількість аніме перевищує 2. Він групує результати за типом жанру та сортує їх за кількістю аніме у спадному порядку.

```SQL
SELECT 
    animes.title_ua,
    animes.anime_status,
    genres.genre_type
FROM public.genres
INNER JOIN public.animes ON genres.anime_id = animes.anime_id;
```

---------
## Рахує кількість майбутніх епізодів для кожного аніме, де дата виходу епізоду дорівнює поточній даті
Опис: Цей запит підраховує кількість майбутніх епізодів для кожного аніме, де дата виходу епізоду дорівнює поточній даті. Він використовує `INNER JOIN` для об'єднання таблиць `animes` та `upcoming_episodes`, фільтрує записи за доступністю аніме та датою виходу епізоду, групує результати за назвою аніме та повертає кількість майбутніх епізодів для кожного аніме.

```SQL
SELECT 
  animes.title_ua,
  animes.title_en,
  count(upcoming_episodes.episode_name) AS upcoming_episodes_count
FROM public.animes
INNER JOIN public.upcoming_episodes 
  ON animes.anime_id = upcoming_episodes.anime_id
WHERE 
  animes.available = TRUE 
  AND upcoming_episodes.episode_date::date = now()::date
GROUP BY animes.title_ua, animes.title_en;
```

## Рахує епізоди у розкладі для кожного аніме
Опис: Цей запит підраховує кількість епізодів у розкладі для кожного аніме. Він групує результати за ідентифікатором аніме та повертає кількість епізодів у розкладі для кожного аніме.

```SQL
SELECT 
    anime_id,
    count(episode_name) AS upcoming_episodes_count
FROM public.upcoming_episodes
GROUP BY anime_id;
```

## Рахує кількість епізодів у розкладі для кожного аніме
Опис: Цей запит підраховує кількість епізодів у розкладі для кожного аніме. Він групує результати за ідентифікатором аніме та повертає кількість епізодів у розкладі для кожного аніме, якщо ця кількість перевищує 1.

```SQL
SELECT 
    anime_id,
    count(episode_name) AS episodes_in_schedule
FROM public.upcoming_episodes
GROUP BY anime_id
HAVING count(episode_name) > 1;
```