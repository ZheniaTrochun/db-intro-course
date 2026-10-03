CREATE TYPE anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE anime_list_units(
  user_id UUID NOT NULL,
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  watched_episodes INTEGER NOT NULL DEFAULT 0 CHECK (watched_episodes >= 0),
  repeat_times INTEGER NOT NULL DEFAULT 0 CHECK (repeat_times >= 0),
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',

  PRIMARY KEY(user_id, anime_id)
);
