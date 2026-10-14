--- BY @XXMARIAVXX
--- Рахує кількість аніме за статусом

SELECT
    anime_status,
    count(*) AS total_count_animes
FROM public.animes
WHERE available = TRUE
  AND anime_status IS NOT NULL
GROUP BY anime_status
ORDER BY total_count_animes DESC;

--- Статистика аніме за студією

SELECT
    production_studio,
    count(*),
    sum(episodes_count),
    round(avg(NULLIF(avg_episode_duration, 0)), 1)
FROM public.animes
WHERE production_studio <> ''
GROUP BY production_studio
ORDER BY sum(episodes_count) DESC, production_studio;

--- Статистика аніме за форматом

SELECT
    anime_format,
    count(*),
    round(avg(episodes_count), 1),
    max(episodes_count),
    min(episodes_count)
FROM public.animes
GROUP BY anime_format
ORDER BY count(*) DESC;

--- Рахує кількість аніме за жанром (LEFT JOIN)

SELECT
    unnest,
    count(public.genres.anime_id)
FROM unnest(enum_range(NULL::public.genre_type_enum))
LEFT JOIN public.genres ON public.genres.genre_type = unnest
GROUP BY unnest
ORDER BY count(public.genres.anime_id) DESC, unnest;

--- Рахує кількість аніме за жанром, де кількість аніме більше 2

SELECT
    genre_type,
    count(*)
FROM public.genres
GROUP BY genre_type
HAVING count(*) > 2
ORDER BY count(*) DESC, genre_type;

--- Рахує кількість епізодів, що виходять сьогодні, для кожного доступного аніме (INNER JOIN)

SELECT
        public.animes.anime_id,
        public.animes.title_ua,
        public.animes.title_en,
        count(public.upcoming_episodes.episode_name)
FROM public.animes
INNER JOIN public.upcoming_episodes ON public.upcoming_episodes.anime_id = public.animes.anime_id
WHERE public.animes.available = TRUE
    AND public.upcoming_episodes.episode_date >= current_date
    AND public.upcoming_episodes.episode_date <  current_date + 1
GROUP BY public.animes.anime_id, public.animes.title_ua, public.animes.title_en
ORDER BY count(public.upcoming_episodes.episode_name) DESC;

--- Рахує всі заплановані епізоди для кожного аніме

SELECT
    public.animes.anime_id,
    public.animes.title_ua,
    count(public.upcoming_episodes.episode_name)
FROM public.upcoming_episodes
INNER JOIN public.animes ON public.animes.anime_id = public.upcoming_episodes.anime_id
GROUP BY public.animes.anime_id, public.animes.title_ua
ORDER BY count(public.upcoming_episodes.episode_name) DESC;

--- Аніме, у яких у розкладі більше одного епізоду

SELECT
    anime_id,
    count(episode_name)
FROM public.upcoming_episodes
GROUP BY anime_id
HAVING count(episode_name) > 1
ORDER BY count(episode_name) DESC;

--- Аніме з кількістю серій більшою за середню (підзапит у WHERE)

SELECT title_ua, episodes_count
FROM public.animes
WHERE episodes_count > (
    SELECT avg(episodes_count)
    FROM public.animes
    WHERE episodes_count > 0
)
ORDER BY episodes_count DESC;

--- Студії з середньою кількістю серій вище загальної середньої (підзапит у HAVING)

SELECT
    production_studio,
    round(avg(episodes_count), 1)
FROM public.animes
WHERE production_studio <> ''
GROUP BY production_studio
HAVING avg(episodes_count) > (SELECT avg(episodes_count) FROM public.animes WHERE episodes_count > 0)
ORDER BY round(avg(episodes_count), 1) DESC;

--- Топ 10 аніме за кількістю завантажених серій (підзапит у SELECT)

SELECT
    public.animes.title_ua,
    (SELECT count(*)
    FROM public.episodes
    WHERE public.episodes.anime_id = public.animes.anime_id)
FROM public.animes
ORDER BY (SELECT count(*)
        FROM public.episodes
        WHERE public.episodes.anime_id = public.animes.anime_id) DESC,
        public.animes.title_ua
LIMIT 10;

--- Звірка користувачів зі списками аніме (FULL JOIN)

SELECT
    public.users.user_id,
    public.anime_list_units.user_id,
    count(public.anime_list_units.anime_id)
FROM public.users
FULL JOIN public.anime_list_units ON public.anime_list_units.user_id = public.users.user_id
GROUP BY public.users.user_id, public.anime_list_units.user_id
ORDER BY count(public.anime_list_units.anime_id) DESC;

--- Середня оцінка за жанром (багатотабличне об'єднання з агрегацією)

SELECT
        public.genres.genre_type,
        count(*),
        round(avg(public.anime_list_units.grade), 2)
FROM public.genres
INNER JOIN public.animes ON public.animes.anime_id = public.genres.anime_id
INNER JOIN public.anime_list_units ON public.anime_list_units.anime_id = public.animes.anime_id
WHERE public.animes.available = TRUE
    AND public.anime_list_units.grade IS NOT NULL
GROUP BY public.genres.genre_type
HAVING count(*) >= 3
ORDER BY round(avg(public.anime_list_units.grade), 2) DESC;

--- Аніме з найбільшою кількістю серій

SELECT title_ua, episodes_count
FROM public.animes
WHERE episodes_count = (SELECT max(episodes_count) FROM public.animes);

--- BY @APOSTOLQLEG
--- Запит, що повертає топ 10 найактивніших коментаторів

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

--- Запит, що повертає топ 10 людей за кількістю завершених аніме

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

--- Запит, що повертає топ 10 аніме за кількістю коментарів

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

--- Запит, що повертає топ 10 жанрів за кількістю коментарів відповідних аніме

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

--- Запит, що повертає топ 10 регіонів за і з відсотком сесій користувачів в цьому регіоні

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

--- Запит, що повертає дуже багато статистичної публічної інформації користувача для профілю

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

--- BY @DADENCUKILLIA
--- Вирахування оцінки та повернення полей аніме

SELECT
    a.anime_id, a.slug, a.title_ua,
    round(avg(lu.grade), 0) AS grade,
    count(lu.grade) AS grades_count
FROM public.anime_list_units lu
INNER JOIN animes AS a ON
    a.anime_id = lu.anime_id
WHERE
    lu.anime_id = '40404040-4040-4040-4040-404040404040' -- replace ID here
GROUP BY a.anime_id, a.slug, a.title_ua;

--- Недоперекладені аніме

SELECT a.anime_id, b.episodes_count AS anime_episodes, max(a.translated_eps) AS translated_episodes
FROM (
    SELECT anime_id, localization_studio, localization_type, count(*) AS translated_eps
    FROM public.episodes
    GROUP BY anime_id, localization_studio, localization_type
) a
CROSS JOIN public.animes b
WHERE
    b.anime_id = a.anime_id
GROUP BY a.anime_id, b.episodes_count
HAVING
    b.episodes_count IS NULL
    OR max(a.translated_eps) < b.episodes_count;

--- Кількість покинутих anime_list_units (якщо юзер кудись зник)

SELECT count(*)
FROM public.anime_list_units lu
LEFT JOIN public.users u ON
    u.user_id = lu.user_id
WHERE u.user_id IS NULL;

--- Найулюбленіші жанри юзера

SELECT 
    a.genre_type,
    rank() OVER (ORDER BY a.watched_times DESC) AS genre_rank
FROM (
    SELECT g.genre_type, count(*) AS watched_times
    FROM public.anime_list_units lu
    INNER JOIN public.genres g ON
        g.anime_id = lu.anime_id
    WHERE
        lu.user_id = '14881488-1488-1488-1488-148814881488' -- replace ID here
    GROUP BY g.genre_type
) a
ORDER BY genre_rank ASC
LIMIT 5
OFFSET 5 * 0;

--- Тривіальний запит для підрахунку індексу терплячості жанрів

SELECT
    g.genre_type,
    coalesce(avg(lu.watched_episodes), 0) / greatest(1, max(a.episodes_count)) AS patience_index
FROM public.genres g
INNER JOIN public.animes a ON
    a.anime_id = g.anime_id
LEFT JOIN public.anime_list_units lu ON
    lu.anime_id = g.anime_id
    AND lu.list_unit_status <> 'watching'
GROUP BY g.genre_type
ORDER BY patience_index DESC;

