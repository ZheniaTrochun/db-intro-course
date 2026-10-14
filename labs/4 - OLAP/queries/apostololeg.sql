-- Запит, що повертає топ 10 найактивніших коментаторів

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


-- Запит, що повертає топ 10 людей за кількістю завершених аніме

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


-- Запит, що повертає топ 10 аніме за кількістю коментарів

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


-- Запит, що повертає топ 10 жанрів за кількістю коментарів відповідних аніме

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


-- Запит, що повертає топ 10 регіонів за і з відсотком сесій користувачів в цьому регіоні

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

-- Запит, що повертає дуже багато статистичної публічної інформації користувача для профілю

SELECT
    u.user_id, 
    u.nickname,
    count(lu.anime_id) AS list_size,
    count(*) FILTER (WHERE lu.list_unit_status = 'finished') AS finished,
    coalesce(sum(lu.watched_episodes), 0) AS episodes_watched,
    round(coalesce(sum(lu.watched_episodes * a.avg_episode_duration), 0) / 60.0, 1) AS hours_watched,
    round(avg(lu.grade), 2) AS avg_grade,
    (
        SELECT count(*) 
        FROM public.comments c 
        WHERE c.author_id = u.user_id
    ) AS comments_total
FROM public.users u
LEFT JOIN public.anime_list_units lu ON lu.user_id = u.user_id
LEFT JOIN public.animes a ON a.anime_id = lu.anime_id
WHERE u.user_id = '14881488-1488-1488-1488-148814881488'
GROUP BY u.user_id, u.nickname;