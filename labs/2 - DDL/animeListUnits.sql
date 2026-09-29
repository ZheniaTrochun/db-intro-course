CREATE TYPE anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE anime_list_units(
  user_id UUID REFERENCES users(user_id),
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  watched_episodes INTEGER NOT NULL DEFAULT 0,
  repeat_times INTEGER NOT NULL DEFAULT 0,
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',

  PRIMARY KEY(user_id, anime_id)
);

CREATE INDEX idx_anime_list_unit_user_id ON anime_list_units(user_id);

--- INSERT EXAMPLES ---

INSERT INTO anime_list_units(user_id, anime_id, watched_episodes, repeat_times, started_watching, list_unit_status) VALUES
  ( '00000000-0000-7000-8000-000000000001', '11111111-1111-1111-1111-111111111111', 0, 0, '2017-03-14', 'watching' ),
  ( '00000000-0000-7000-8000-000000000003', '11111111-6666-1111-2222-111119999999', 2, 0, now()::date, 'finished' ),
  ( '00000000-0000-7000-8000-000000000002', '11111111-1111-1111-1111-111111111111', 5, 1, CURRENT_DATE, 'dropped' ),
  ( '00000000-0000-7000-8000-000000000001', '11111111-6666-1111-2222-111119999999', 0, 1, '2022-11-25', 'watching' ),
  ( '00000000-0000-7000-8000-000000000002', '11111111-6666-1111-2222-111119999999', 5, 5, '2026-09-27', 'finished' ),
  ( '00000000-0000-7000-8000-000000000001', '44444444-4444-4444-4444-444444444444', 2, 3, '2011-03-05', 'delayed' ),
  ( '00000000-0000-7000-8000-000000000001', '33333333-3333-3333-3333-333333333333', 3, 3, '2000-03-03', 'delayed' ),
  ( '00000000-0000-7000-8000-000000000003', '11111111-1111-1111-1111-111111111111', 15, 4, '1971-01-14', 'finished' );
