CREATE TABLE upcomingEpisodes (
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT PRIMARY KEY,
  episode_date TIMESTAMP NOT NULL
)