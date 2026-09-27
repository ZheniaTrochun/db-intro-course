CREATE TYPE anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE animeListUnits(
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  watched_episodes INTEGER NOT NULL DEFAULT 0,
  repeat_times INTEGER NOT NULL DEFAULT 0,
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',

  PRIMARY KEY(user_id, anime_id)
);

CREATE INDEX idx_anime_list_unit_user_id ON animeListUnits(user_id);
