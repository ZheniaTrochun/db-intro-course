CREATE TYPE episode_localization_type_enum AS ENUM('sub', 'dub', 'original');

CREATE TABLE episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  source_url TEXT,
  episode_name TEXT NOT NULL,
  localization_studio TEXT,
  localization_type episode_localization_type_enum NOT NULL DEFAULT 'dub'
);

CREATE INDEX idx_episodes_anime_id ON episodes(anime_id);
