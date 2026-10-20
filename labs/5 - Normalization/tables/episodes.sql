CREATE TYPE public.episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE IF NOT EXISTS public.episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL UNIQUE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  localization_studio TEXT NOT NULL DEFAULT '',
  localization_type episode_localization_type_enum
);

CREATE INDEX IF NOT EXISTS idx_episodes_anime_id ON public.episodes(anime_id);
