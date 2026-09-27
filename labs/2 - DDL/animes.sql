CREATE TYPE anime_format AS ENUM ('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE anime_status AS ENUM ('upcoming', 'ongoing', 'dropped', 'finished', 'unknown');

CREATE TABLE animes (
  anime_id UUID PRIMARY KEY DEFAULT UUIDv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT,
  title_en TEXT,
  title_original TEXT,
  description TEXT,
  cover_url TEXT,
  production_studio TEXT,
  mal_id INT,
  anilist_id INT,
  hikka_id INT UNIQUE,
  imdb_id INT UNIQUE,
  year INT SMALLINT CHECK (year >= 1900 AND year <= 2100),
  avg_episode_duration INT,
  pegi_age_restriction INT,
  anime_status anime_status NOT NULL,
  anime_format anime_format NOT NULL
)