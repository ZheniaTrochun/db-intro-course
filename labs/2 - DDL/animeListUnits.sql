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

--- INSERT EXAMPLES ---

INSERT INTO animeListUnits(user_id, anime_id) VALUES
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ab-4889-7461-93c3-4219d0f94f32' ),
  ( '01a0e3ab-fc3d-770e-971e-d34cf6ca9b1e', '01a0e3ac-adbc-768a-849c-cbefb8561a11' ),
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ac-cd9c-702b-af73-72bb40da2781' ),
  ( '01a0e3ac-4879-7631-9fd3-5a06d93a4377', '01a0e3ab-4889-7461-93c3-4219d0f94f32' ),
  ( '01a0e3ac-61a9-70eb-a8a2-e871d7d2904f', '01a0e3ac-7d85-716a-a89f-0012cd2d41e7' ),
  ( '01a0e3ac-3585-7339-9035-9f929b31340f', '01a0e3ab-4889-7461-93c3-4219d0f94f32' ),
  ( '01a0e3ab-ddd2-71db-b0ba-86d9ac5252f5', '01a0e3ac-bde5-7308-b529-9b379d743eef' ),
  ( '01a0e3ac-1778-713a-8265-2731d75ec20d', '01a0e3ac-97ed-76a9-8fb1-07599a9b6b7c' );

INSERT INTO animeListUnits(user_id, anime_id, watched_episodes, repeat_times) VALUES
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 0, 0 ),
  ( '01a0e3ab-fc3d-770e-971e-d34cf6ca9b1e', '01a0e3ac-adbc-768a-849c-cbefb8561a11', 2, 0 ),
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ac-cd9c-702b-af73-72bb40da2781', 5, 1 ),
  ( '01a0e3ac-4879-7631-9fd3-5a06d93a4377', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 0, 1 ),
  ( '01a0e3ac-61a9-70eb-a8a2-e871d7d2904f', '01a0e3ac-7d85-716a-a89f-0012cd2d41e7', 5, 5 ),
  ( '01a0e3ac-3585-7339-9035-9f929b31340f', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 2, 3 ),
  ( '01a0e3ab-ddd2-71db-b0ba-86d9ac5252f5', '01a0e3ac-bde5-7308-b529-9b379d743eef', 3, 3 ),
  ( '01a0e3ac-1778-713a-8265-2731d75ec20d', '01a0e3ac-97ed-76a9-8fb1-07599a9b6b7c', 5, 4 );

INSERT INTO animeListUnits(user_id, anime_id, watched_episodes, repeat_times, started_watching) VALUES
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 0, 0, '2017-03-14' ),
  ( '01a0e3ab-fc3d-770e-971e-d34cf6ca9b1e', '01a0e3ac-adbc-768a-849c-cbefb8561a11', 2, 0, now()::date ),
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ac-cd9c-702b-af73-72bb40da2781', 5, 1, CURRENT_DATE ),
  ( '01a0e3ac-4879-7631-9fd3-5a06d93a4377', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 0, 1, '2022-11-25' ),
  ( '01a0e3ac-61a9-70eb-a8a2-e871d7d2904f', '01a0e3ac-7d85-716a-a89f-0012cd2d41e7', 5, 5, '2026-09-27' ),
  ( '01a0e3ac-3585-7339-9035-9f929b31340f', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 2, 3, '2011-03-05' ),
  ( '01a0e3ab-ddd2-71db-b0ba-86d9ac5252f5', '01a0e3ac-bde5-7308-b529-9b379d743eef', 3, 3, '2000-03-03' ),
  ( '01a0e3ac-1778-713a-8265-2731d75ec20d', '01a0e3ac-97ed-76a9-8fb1-07599a9b6b7c', 5, 4, '1971-01-14' );

INSERT INTO animeListUnits(user_id, anime_id, watched_episodes, repeat_times, started_watching, list_unit_status) VALUES
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 0, 0, '2017-03-14', 'watching' ),
  ( '01a0e3ab-fc3d-770e-971e-d34cf6ca9b1e', '01a0e3ac-adbc-768a-849c-cbefb8561a11', 2, 0, now()::date, 'finished' ),
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', '01a0e3ac-cd9c-702b-af73-72bb40da2781', 5, 1, CURRENT_DATE, 'dropped' ),
  ( '01a0e3ac-4879-7631-9fd3-5a06d93a4377', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 0, 1, '2022-11-25', 'watching' ),
  ( '01a0e3ac-61a9-70eb-a8a2-e871d7d2904f', '01a0e3ac-7d85-716a-a89f-0012cd2d41e7', 5, 5, '2026-09-27', 'finished' ),
  ( '01a0e3ac-3585-7339-9035-9f929b31340f', '01a0e3ab-4889-7461-93c3-4219d0f94f32', 2, 3, '2011-03-05', 'delayed' ),
  ( '01a0e3ab-ddd2-71db-b0ba-86d9ac5252f5', '01a0e3ac-bde5-7308-b529-9b379d743eef', 3, 3, '2000-03-03', 'delayed' ),
  ( '01a0e3ac-1778-713a-8265-2731d75ec20d', '01a0e3ac-97ed-76a9-8fb1-07599a9b6b7c', 15, 4, '1971-01-14', 'finished' );
