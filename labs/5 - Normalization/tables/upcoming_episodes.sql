CREATE TABLE upcoming_episodes(
  upcoming_episode_id UUID PRIMARY KEY DEFAULT uuidv7(),
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(anime_id, episode_name)
);
