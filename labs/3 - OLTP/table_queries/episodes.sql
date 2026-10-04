CREATE TYPE episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  localization_studio TEXT NOT NULL DEFAULT '',
  localization_type episode_localization_type_enum
);

CREATE INDEX idx_episodes_anime_id ON episodes(anime_id);

--- INSERT EXAMPLES ---

INSERT INTO episodes(anime_id, source_url, episode_name, localization_studio, localization_type) VALUES
  ( '11111111-1111-1111-1111-111111111111', 'https://example/video.mp4', 'Recap', 'FanVoxUA', 'dub' ),
  ( '11111111-6666-1111-2222-111119999999', 'https://lorem.video/720p', 'Ending', 'Amanogawa', 'dub' ),
  ( '44444444-4444-4444-4444-444444444444', 'https://ashdi.vip/090211.m3u', 'Opening', 'ToBeContinued', 'dub' ),
  ( '11111111-1111-1111-1111-111111111111', 'https://moonanime.com/54464.m3u', 'Promo', 'Clan Kaizoku', 'sub' ),
  ( '11111111-6666-1111-2222-111119999999', 'https://cdn.vimeo.com/3989895930.mp4', 'Special episode', 'Glass Moon', 'dub' ),
  ( '33333333-3333-3333-3333-333333333333', 'https://kokosf.tv/rwrwrwtgd.mp4', 'EP1', 'FanVoxUA', 'sub' ),
  ( '44444444-4444-4444-4444-444444444444', 'https://notavirus.su/watch_please.mp4', 'EP12.5', 'Gwen & Maslinka', 'dub' ),
  ( '11111111-6666-1111-2222-111119999999', 'https://minecraft.net/promo.mp4', 'OVA1', 'AniUA', 'dub' );
