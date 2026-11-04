BEGIN;

-- users

INSERT INTO users (user_id, nickname, full_name, email, password_hash) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'demo_user', 'John Johnson',  'demo@example.com',  'demo-not-a-real-hash'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'demo_user2', 'Peter Peterson', 'demo2@example.com', 'demo-not-a-real-hash');

-- animes
INSERT INTO animes (
  anime_id, slug, title_ua, title_en, title_original, cover_url, production_studio,
  mal_id, anilist_id, year_released, avg_episode_duration, episode_count,
  age_restriction, anime_status, anime_format, available
) VALUES
('11111111-1111-1111-1111-111111111111', 'frieren-beyond-journeys-end',
 'Фрірен, що проводжає в останню путь', 'Frieren: Beyond Journey''s End', '葬送のフリーレン',
 'https://example.com/covers/frieren.jpg', 'Madhouse',
 52991, 154587, 2023, 24, 28, 'pg13', 'finished', 'tv', true),

('22222222-2222-2222-2222-222222222222', 'cowboy-bebop',
 'Ковбой Бібоп', 'Cowboy Bebop', 'カウボーイビバップ',
 'https://example.com/covers/bebop.jpg', 'Sunrise',
 1, 1, 1998, 24, 26, 'r', 'finished', 'tv', true),

('33333333-3333-3333-3333-333333333333', 'steins-gate',
 'Врата Штайнера', 'Steins;Gate', 'シュタインズ・ゲート',
 'https://example.com/covers/steins-gate.jpg', 'White Fox',
 9253, 9253, 2011, 24, 24, 'pg13', 'finished', 'tv', true),

('44444444-4444-4444-4444-444444444444', 'spy-x-family',
 'Сім''я шпигуна', 'Spy x Family', 'SPY×FAMILY',
 'https://example.com/covers/spy-x-family.jpg', 'Wit Studio, CloverWorks',
 50265, 140960, 2022, 24, 37, 'pg13', 'ongoing', 'tv', true),

('55555555-5555-5555-5555-555555555555', 'demo-upcoming-movie',
 'Демо: Майбутній фільм', 'Demo: Upcoming Movie', 'デモ映画',
 NULL, 'Demo Studio',
 NULL, NULL, 2027, 110, 1, 'pg', 'upcoming', 'movie', true);

-- genres
INSERT INTO genres (anime_id, genre_type, is_primary) VALUES
('11111111-1111-1111-1111-111111111111', 'adventure', true),
('11111111-1111-1111-1111-111111111111', 'fantasy',   false),
('11111111-1111-1111-1111-111111111111', 'drama',     false),

('22222222-2222-2222-2222-222222222222', 'sci_fi',    true),
('22222222-2222-2222-2222-222222222222', 'action',    false),
('22222222-2222-2222-2222-222222222222', 'adventure', false),

('33333333-3333-3333-3333-333333333333', 'sci_fi',    true),
('33333333-3333-3333-3333-333333333333', 'thriller',  false),
('33333333-3333-3333-3333-333333333333', 'drama',     false),

('44444444-4444-4444-4444-444444444444', 'comedy',    true),
('44444444-4444-4444-4444-444444444444', 'action',    false),
('44444444-4444-4444-4444-444444444444', 'slice_of_life', false),

('55555555-5555-5555-5555-555555555555', 'fantasy',   true),
('55555555-5555-5555-5555-555555555555', 'adventure', false);

-- upcoming_episodes
INSERT INTO upcoming_episodes (anime_id, episode_name, episode_date) VALUES
('44444444-4444-4444-4444-444444444444', 'Серія 38', now() + interval '2 days'),
('44444444-4444-4444-4444-444444444444', 'Серія 39', now() + interval '9 days'),
('44444444-4444-4444-4444-444444444444', 'Серія 40', now() + interval '16 days'),
('55555555-5555-5555-5555-555555555555', 'Прем''єра фільму', now() + interval '60 days');

-- episodes
INSERT INTO episodes (anime_id, source_url, episode_name, localization_studio, localization_type) VALUES
('11111111-1111-1111-1111-111111111111', 'https://example.com/video/frieren/1-dub', 'Серія 1', 'Demo Dub Studio', 'dub'),
('11111111-1111-1111-1111-111111111111', 'https://example.com/video/frieren/1-sub', 'Серія 1', 'Demo Sub Team',   'sub'),
('11111111-1111-1111-1111-111111111111', 'https://example.com/video/frieren/2-dub', 'Серія 2', 'Demo Dub Studio', 'dub'),
('22222222-2222-2222-2222-222222222222', 'https://example.com/video/bebop/1-sub',   'Серія 1', 'Demo Sub Team',   'sub'),
('22222222-2222-2222-2222-222222222222', 'https://example.com/video/bebop/2-sub',   'Серія 2', 'Demo Sub Team',   'sub'),
('33333333-3333-3333-3333-333333333333', 'https://example.com/video/steins-gate/1-dub', 'Серія 1', 'Demo Dub Studio', 'dub'),
('44444444-4444-4444-4444-444444444444', 'https://example.com/video/spy-x-family/1-dub', 'Серія 1', 'Demo Dub Studio', 'dub'),
('44444444-4444-4444-4444-444444444444', 'https://example.com/video/spy-x-family/2-dub', 'Серія 2', 'Demo Dub Studio', 'dub');

-- anime_list_units
INSERT INTO anime_list_units (user_id, anime_id, watched_episodes, repeat_times, list_unit_status, grade)
SELECT u.user_id, v.anime_id::uuid, v.watched, v.repeats, v.status::anime_list_unit_status_enum, v.grade
FROM (SELECT user_id FROM users ORDER BY user_id LIMIT 1) u
CROSS JOIN (VALUES
  ('11111111-1111-1111-1111-111111111111', 28, 1, 'finished', 10),
  ('22222222-2222-2222-2222-222222222222', 12, 0, 'watching', 9),
  ('33333333-3333-3333-3333-333333333333', 24, 2, 'finished', 10),
  ('44444444-4444-4444-4444-444444444444',  5, 0, 'delayed',  NULL)
) AS v(anime_id, watched, repeats, status, grade);

-- sessions
INSERT INTO sessions (user_id, refresh_token, device_type, device_name, os, browser, user_location, ip_address, expire_time)
SELECT u.user_id,
       decode(replace(gen_random_uuid()::text, '-', ''), 'hex'),
       v.device_type, v.device_name, v.os, v.browser, v.location, v.ip::inet, v.expire
FROM (SELECT user_id FROM users ORDER BY user_id LIMIT 1) u
CROSS JOIN (VALUES
  ('desktop', 'Home PC',   'Linux',   'Firefox', 'Київ, UA',  '192.168.1.10', now() + interval '180 days'),
  ('mobile',  'Pixel 8',   'Android', 'Chrome',  'Львів, UA', '192.168.1.11', now() + interval '90 days'),
  ('desktop', 'Old laptop','Windows', 'Edge',    'Рівне, UA', '192.168.1.12', now() - interval '5 days')  -- прострочена, для демо очищення
) AS v(device_type, device_name, os, browser, location, ip, expire);

COMMIT;
