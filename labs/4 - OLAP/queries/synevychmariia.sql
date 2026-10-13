SELECT 
    anime_status,
    count(*) AS total_count_animes
FROM public.animes
WHERE 
    available = TRUE AND
    anime_status IS NOT NULL
GROUP BY anime_status;

SELECT episode_count,
    count(*) AS total_count_episodes
FROM public.animes, episodes
WHERE 
    available = TRUE
    AND episodes.anime_id = animes.anime_id
GROUP BY episode_count;

SELECT 
  production_studio,
  count(DISTINCT anime_id) AS total_animes,
  sum(episodes_count) AS total_episodes,
  round(avg(avg_episode_duration), 1) AS avg_duration
FROM animes
WHERE production_studio IS NOT NULL
GROUP BY production_studio
ORDER BY total_episodes DESC;

SELECT 
    anime_format,
    count(anime_id) AS total_titles,
    round(avg(episodes_count), 1) AS avg_episodes,
    max(episodes_count) AS max_episodes,
    min(episodes_count) AS min_episodes
FROM public.animes
GROUP BY anime_format;

SELECT 
  genres.genre_type,
  count(animes.anime_id) AS anime_count
FROM genres
LEFT JOIN animes ON genres.anime_id = animes.anime_id
GROUP BY genres.genre_type
ORDER BY anime_count DESC, genres.genre_type DESC;

SELECT 
    genre_type,
    count(anime_id) AS anime_count
FROM public.genres
GROUP BY genre_type
HAVING count(anime_id) > 2
ORDER BY anime_count DESC;

SELECT 
    animes.title_ua,
    animes.anime_status,
    genres.genre_type
FROM public.genres
INNER JOIN public.animes ON genres.anime_id = animes.anime_id;

SELECT 
  animes.title_ua,
  animes.title_en,
  count(upcoming_episodes.episode_name) AS upcoming_episodes_count
FROM animes, upcoming_episodes
WHERE 
  animes.anime_id = upcoming_episodes.anime_id AND
  animes.available = TRUE AND 
  upcoming_episodes.episode_date::date = now()::date
GROUP BY animes.title_ua, animes.title_en;

SELECT 
    anime_id,
    count(episode_name) AS upcoming_episodes_count
FROM public.upcoming_episodes
GROUP BY anime_id;

SELECT 
    anime_id,
    count(episode_name) AS episodes_in_schedule
FROM public.upcoming_episodes
GROUP BY anime_id
HAVING count(episode_name) > 1;