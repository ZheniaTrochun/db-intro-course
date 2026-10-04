CREATE TABLE upcoming_episodes(
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  PRIMARY KEY(anime_id, episode_name)
);

CREATE INDEX idx_upcoming_episode_date ON upcoming_episodes(episode_date ASC);

--- INSERT EXAMPLES ---

INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date) VALUES
  ('11111111-1111-1111-1111-111111111111', 'EP2', now() + INTERVAL '7 days'),
  ('11111111-6666-1111-2222-111119999999', 'EP3', now()::date + INTERVAL '30 days' + TIME '12:00:00'),
  ('44444444-4444-4444-4444-444444444444', 'Infinity Castle Arc: Part 1', now() + INTERVAL '90 days'),
  ('33333333-3333-3333-3333-333333333333', 'The Final Battle Begins', now()::date + INTERVAL '30 days' + TIME '17:30:00');

