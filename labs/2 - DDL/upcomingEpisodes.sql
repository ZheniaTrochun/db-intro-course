-- DDL for upcomingEpisodes table

CREATE TABLE upcoming_episodes(
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT,
  episode_date TIMESTAMP NOT NULL DEFAULT NOW(),

  PRIMARY KEY(anime_id, episode_date)
);

--- INSERT EXAMPLES ---

INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date) VALUES
  ('11111111-1111-1111-1111-111111111111', 'EP2', NOW() + INTERVAL '7 days'),
  ('11111111-6666-1111-2222-111119999999', 'EP3', CURRENT_DATE + INTERVAL '30 days' + TIME '12:00:00'),
  ('44444444-4444-4444-4444-444444444444', 'Infinity Castle Arc: Part 1', NOW() + INTERVAL '90 days'),
  ('33333333-3333-3333-3333-333333333333', 'The Final Battle Begins', CURRENT_DATE + INTERVAL '30 days' + TIME '17:30:00');

