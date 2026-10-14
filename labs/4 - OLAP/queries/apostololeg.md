## Запит, що повертає топ 10 найактивніших коментаторів
**Опис**: Запит підраховує загальну кількість коментарів для кожного користувача за допомогою `INNER JOIN` та повертає 10 найактивніших авторів у порядку спадання кількості коментарів.
**Використано:** `COUNT`, `GROUP BY`, `INNER JOIN`.
```SQL
SELECT
    users.nickname,
    count(comments.comment_id) AS total_comments
FROM public.comments
INNER JOIN public.users ON
    users.user_id = comments.author_id
GROUP BY users.user_id, users.nickname
ORDER BY total_comments DESC, users.nickname ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 людей за кількістю завершених аніме
**Опис:** Запит групує користувачів і підраховує кількість аніме зі статусом «finished» у їхніх списках, повертаючи перших 10 людей.
**Використано:** `COUNT`, `GROUP BY`, `LEFT JOIN`.
```SQL
SELECT
    users.nickname,
    count(list_unit.anime_id) AS finished_count
FROM public.users
LEFT JOIN public.anime_list_units list_unit ON
    users.user_id = list_unit.user_id
    AND list_unit.list_unit_status = 'finished'
GROUP BY users.user_id, users.nickname
ORDER BY finished_count DESC, users.nickname ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 аніме за кількістю коментарів
**Опис:** Запит агрегує коментарі для кожного тайтлу через `RIGHT JOIN` (демонстративний приклад) та виводить 10 найбільш обговорюваних аніме.
**Використано:** `COUNT`, `GROUP BY`, `RIGHT JOIN`
```SQL
SELECT
    animes.title_ua,
    count(comments.comment_id) AS total_comments
FROM public.comments
RIGHT JOIN public.animes ON
    animes.anime_id = comments.anime_id
GROUP BY animes.anime_id, animes.title_ua
ORDER BY total_comments DESC, animes.title_ua ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 жанрів за кількістю коментарів відповідних аніме
**Опис:** Запит об'єднує жанри з коментарями відповідних аніме через `INNER JOIN`, підраховує загальну кількість коментарів у межах кожного жанру та повертає 10 найпопулярніших жанрів за кількістю коментарів.
**Використано:** `COUNT`, `GROUP BY`, `INNER JOIN`
```SQL
SELECT
    genres.genre_type,
    count(comments.comment_id) AS total_comments
FROM public.genres
INNER JOIN public.comments ON
    comments.anime_id = genres.anime_id
GROUP BY genres.genre_type
ORDER BY total_comments DESC, genres.genre_type ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 регіонів за і з відсотком сесій користувачів в цьому регіоні
**Опис:** Запит підраховує кількість сесій для кожного визначеного регіону та обчислює його відсоткову частку від загальної кількості всіх сесій за допомогою вкладеного підзапиту `SELECT`, повертаючи 10 найпопулярніших регіонів.
**Використано:** багато `COUNT`, `GROUP BY`, підзапит `SELECT`
```SQL
SELECT
    sessions.user_location,
    count(sessions.session_id) AS total_sessions,
    round(
        (count(sessions.session_id) * 100.0) / (SELECT count(*) FROM public.sessions), 2) 
    AS session_percentage
FROM public.sessions
WHERE sessions.user_location IS NOT NULL
GROUP BY sessions.user_location
ORDER BY total_sessions DESC, sessions.user_location ASC
LIMIT 10 
OFFSET 10 * 0;
```