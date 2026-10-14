-- Рахує кількість аніме за статусом
SELECT
    anime_status,
    count(*) AS total_count_animes
FROM public.animes
WHERE available = TRUE
  AND anime_status IS NOT NULL
GROUP BY anime_status
ORDER BY total_count_animes DESC;


-- Статистика аніме за студією
SELECT
    production_studio,
    count(*),
    sum(episodes_count),
    round(avg(NULLIF(avg_episode_duration, 0)), 1)
FROM public.animes
WHERE production_studio <> ''
GROUP BY production_studio
ORDER BY sum(episodes_count) DESC, production_studio;


-- Статистика аніме за форматом
SELECT
    anime_format,
    count(*),
    round(avg(episodes_count), 1),
    max(episodes_count),
    min(episodes_count)
FROM public.animes
GROUP BY anime_format
ORDER BY count(*) DESC;


-- Рахує кількість аніме за жанром (LEFT JOIN)
SELECT
    unnest,
    count(public.genres.anime_id)
FROM unnest(enum_range(NULL::public.genre_type_enum))
LEFT JOIN public.genres ON public.genres.genre_type = unnest
GROUP BY unnest
ORDER BY count(public.genres.anime_id) DESC, unnest;


-- Рахує кількість аніме за жанром, де кількість аніме більше 2
SELECT
    genre_type,
    count(*)
FROM public.genres
GROUP BY genre_type
HAVING count(*) > 2
ORDER BY count(*) DESC, genre_type;


-- Рахує кількість епізодів, що виходять сьогодні, для кожного доступного аніме (INNER JOIN)
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


-- Рахує всі заплановані епізоди для кожного аніме
SELECT
    public.animes.anime_id,
    public.animes.title_ua,
    count(public.upcoming_episodes.episode_name)
FROM public.upcoming_episodes
INNER JOIN public.animes ON public.animes.anime_id = public.upcoming_episodes.anime_id
GROUP BY public.animes.anime_id, public.animes.title_ua
ORDER BY count(public.upcoming_episodes.episode_name) DESC;


-- Аніме, у яких у розкладі більше одного епізоду
SELECT
    anime_id,
    count(episode_name)
FROM public.upcoming_episodes
GROUP BY anime_id
HAVING count(episode_name) > 1
ORDER BY count(episode_name) DESC;


-- Аніме з кількістю серій більшою за середню (підзапит у WHERE)
SELECT title_ua, episodes_count
FROM public.animes
WHERE episodes_count > (
    SELECT avg(episodes_count)
    FROM public.animes
    WHERE episodes_count > 0
)
ORDER BY episodes_count DESC;


-- Студії з середньою кількістю серій вище загальної середньої (підзапит у HAVING)
SELECT
    production_studio,
    round(avg(episodes_count), 1)
FROM public.animes
WHERE production_studio <> ''
GROUP BY production_studio
HAVING avg(episodes_count) > (SELECT avg(episodes_count) FROM public.animes WHERE episodes_count > 0)
ORDER BY round(avg(episodes_count), 1) DESC;


-- Топ 10 аніме за кількістю завантажених серій (підзапит у SELECT)
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


-- Звірка користувачів зі списками аніме (FULL JOIN)
SELECT
    public.users.user_id,
    public.anime_list_units.user_id,
    count(public.anime_list_units.anime_id)
FROM public.users
FULL JOIN public.anime_list_units ON public.anime_list_units.user_id = public.users.user_id
GROUP BY public.users.user_id, public.anime_list_units.user_id
ORDER BY count(public.anime_list_units.anime_id) DESC;


-- Середня оцінка за жанром (багатотабличне об'єднання з агрегацією)
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

--Аніме з найбільшою кількістю серій (підзапит у WHERE)
SELECT title_ua, episodes_count
FROM public.animes
WHERE episodes_count = (SELECT max(episodes_count) FROM public.animes);

--Аніме, у яких немає епізодів (NOT EXISTS)
SELECT public.animes.title_ua
FROM public.animes
WHERE NOT EXISTS (
    SELECT *
    FROM public.episodes
    WHERE public.episodes.anime_id = public.animes.anime_id
);