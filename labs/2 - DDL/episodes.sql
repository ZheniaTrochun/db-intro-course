CREATE TYPE episode_localization_type_enum AS ENUM('sub', 'dub', 'original');

CREATE TABLE episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  source_url TEXT,
  episode_name TEXT NOT NULL,
  localization_studio TEXT,
  localization_type episode_localization_type_enum NOT NULL DEFAULT 'dub'
);

CREATE INDEX idx_episodes_anime_id ON episodes(anime_id);

--- INSERT EXAMPLES ---

INSERT INTO episodes(anime_id, source_url, episode_name, localization_studio, localization_type) VALUES
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', 'https://example/video.mp4', 'Recap', 'FanVoxUA', 'dub' ),
  ( '01a0e3ab-fc3d-770e-971e-d34cf6ca9b1e', 'https://lorem.video/720p', 'Ending', 'Amanogawa', 'dub' ),
  ( '01a0e3ab-36bf-715e-85e6-d16c9954c619', 'https://ashdi.vip/090211.m3u', 'Opening', 'ToBeContinued', 'dub' ),
  ( '01a0e3ac-4879-7631-9fd3-5a06d93a4377', 'https://moonanime.com/54464.m3u', 'Promo', 'Clan Kaizoku', 'sub' ),
  ( '01a0e3ac-61a9-70eb-a8a2-e871d7d2904f', 'https://cdn.vimeo.com/3989895930.mp4', 'Special episode', 'Glass Moon', 'dub' ),
  ( '01a0e3ac-3585-7339-9035-9f929b31340f', 'https://kokosf.tv/rwrwrwtgd.mp4', 'EP1', 'FanVoxUA', 'sub' ),
  ( '01a0e3ab-ddd2-71db-b0ba-86d9ac5252f5', 'https://notavirus.su/watch_please.mp4', 'EP12.5', 'Gwen & Maslinka', 'dub' ),
  ( '01a0e3ac-1778-713a-8265-2731d75ec20d', 'https://minecraft.net/promo.mp4', 'OVA1', 'AniUA', 'dub' );
