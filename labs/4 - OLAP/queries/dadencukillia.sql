-- Вирахування оцінки та повернення полей аніме

SELECT a.anime_id, a.slug, a.title_ua, round(avg(lu.grade), 0) AS grade
FROM public.anime_list_units lu
INNER JOIN animes AS a ON
    a.anime_id = lu.anime_id
WHERE
    lu.anime_id = '40404040-4040-4040-4040-404040404040' -- replace ID here
GROUP BY a.anime_id, a.slug, a.title_ua;


-- Недоперекладені аніме

SELECT a.anime_id, b.episodes_count AS anime_episodes, max(a.translated_eps) AS translated_episodes
FROM (
    SELECT anime_id, localization_studio, localization_type, count(*) AS translated_eps
    FROM public.episodes
    GROUP BY anime_id, localization_studio, localization_type
) a
INNER JOIN public.animes b ON
    b.anime_id = a.anime_id
GROUP BY a.anime_id, b.episodes_count
HAVING
    b.episodes_count IS NULL
    OR max(a.translated_eps) < b.episodes_count;


-- Кількість покинутих anime_list_units (якщо юзер кудись зник)

SELECT count(*)
FROM public.anime_list_units lu
LEFT JOIN public.users u ON
    u.user_id = lu.user_id
WHERE u.user_id IS NULL;


-- Найулюбленіші жанри юзера

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
