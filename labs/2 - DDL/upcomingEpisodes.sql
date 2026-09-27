-- DDL for upcomingEpisodes table

CREATE TABLE upcomingEpisodes (
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT PRIMARY KEY,
  episode_date TIMESTAMP NOT NULL DEFAULT NOW()
)

-- TEST
INSERT INTO upcoming_episodes (anime_id, episode_number, episode_date)
VALUES ('11111111-1111-1111-1111-111111111111', 2, NOW() + INTERVAL '7 days');
       ('11111111-6666-1111-2222-111119999999', 3, CURRENT_DATE + INTERVAL '１ month' + TIME '12:00:00');
       ('44444444-4444-4444-4444-444444444444', 1, 'Infinity Castle Arc: Part 1', NOW() + INTERVAL '3 months');
       ('33333333-3333-3333-3333-333333333333', 140, 'The Final Battle Begins', CURRENT_DATE + INTERVAL '1 month' + TIME '17:30:00'),