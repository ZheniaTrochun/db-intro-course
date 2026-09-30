# Лабораторна робота №2

### SQL
```sql
CREATE TYPE user_status_enum AS ENUM('admin', 'banned', 'deactivated');

CREATE TABLE users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT,
    social_networks TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    max_streak INTEGER NOT NULL DEFAULT 0,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_status user_status_enum,
    crated_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_status ON users(user_status);
CREATE INDEX idx_nickname ON users(nickname);

CREATE TYPE anime_format_enum AS ENUM ('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE anime_status_enum AS ENUM ('upcoming', 'ongoing', 'dropped', 'finished');
CREATE TYPE mpaa_rating_enum AS ENUM (
  'g',    -- General Audiences (Без обмежень)
  'pg',   -- Parental Guidance Suggested (Рекомендовано перегляд з батьками)
  'pg13', -- Parents Strongly Cautioned (Дітям до 13 років небажано)
  'r',    -- Restricted (До 17 років тільки з дорослими)
  'nc17'  -- No One 17 and Under Admitted (Категорично з 18 років)
);

CREATE TABLE animes(
  anime_id UUID PRIMARY KEY DEFAULT uuidv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT,
  title_en TEXT,
  title_original TEXT,
  anime_description TEXT,
  cover_url TEXT,
  production_studio TEXT,
  mal_id INT,
  anilist_id INT,
  hikka_id INT,
  imdb_id INT,
  year_released SMALLINT CHECK (year_released >= 1900),
  avg_episode_duration SMALLINT NOT NULL DEFAULT 0,
  age_restriction mpaa_rating_enum,
  anime_status anime_status_enum,
  anime_format anime_format_enum NOT NULL DEFAULT 'tv',
  available BOOLEAN NOT NULL DEFAULT TRUE
);

-- DDL for upcomingEpisodes table

CREATE TABLE upcoming_episodes(
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT,
  episode_date TIMESTAMP NOT NULL DEFAULT NOW(),

  PRIMARY KEY(anime_id, episode_date)
);

CREATE TABLE sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token CHAR(128) NOT NULL UNIQUE,
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX idx_sessions_refresh_token ON sessions(refresh_token);

CREATE TYPE genre_type_enum AS ENUM(
    'action',
    'adventure',
    'avant_garde',
    'boys_love',
    'comedy',
    'demons',
    'drama',
    'ecchi',
    'fantasy',
    'girls_love',
    'gourmet',
    'harem',
    'hentai',
    'historical',
    'horror',
    'isekai',
    'josei',
    'kids',
    'magic',
    'martial_arts',
    'mecha',
    'military',
    'music',
    'mystery',
    'parody',
    'psychological',
    'romance',
    'samurai',
    'school',
    'sci_fi',
    'seinen',
    'shoujo',
    'shoujo_ai',
    'shounen',
    'shounen_ai',
    'slice_of_life',
    'space',
    'sports',
    'supernatural',
    'super_power',
    'suspense',
    'thriller',
    'vampire'
);

CREATE TABLE genres(
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  genre_type genre_type_enum NOT NULL UNIQUE,

  PRIMARY KEY(anime_id, genre_type)
);

CREATE TYPE episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL,
  episode_name TEXT NOT NULL,
  localization_studio TEXT,
  localization_type episode_localization_type_enum
);

CREATE INDEX idx_episodes_anime_id ON episodes(anime_id);

CREATE TABLE comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
    grade SMALLINT CHECK (grade BETWEEN -5 AND 5),
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_comments_anime_id ON comments(anime_id);

CREATE INDEX inx_anime_slug ON animes(slug);
CREATE INDEX inx_anime_available ON animes(available);

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

INSERT INTO animes(
  anime_id, slug,
  title_ua, title_en, title_original,
  anime_description,
  cover_url,
  production_studio,
  mal_id, anilist_id, hikka_id, imdb_id,
  year_released,
  avg_episode_duration,
  age_restriction,
  anime_status, anime_format, available
) VALUES
  ( '11111111-1111-1111-1111-111111111111', 'one-piece', 'Ван-Піс', 'One Piece', 'ワンピース', 'A long-running adventure anime about pirates searching for the ultimate treasure.', 'https://example.com/one-piece.jpg', 'Toei Animation', 55667, 88990, 223344, 151617, 1999, 24, 'pg13', 'ongoing', 'tv', TRUE ),
  ( '11111111-6666-1111-2222-111119999999', 'spy-x-family', 'Шпигунська родина', 'Spy x Family', 'スパイファミリー', 'A comedy-action anime about a spy who must build a fake family to complete his mission.', 'https://example.com/spy-x-family.jpg', 'WIT Studio', 22334, 55667, 88990, 101112, 2022, 23, 'pg13', 'ongoing', 'tv', TRUE ),
  ( '33333333-3333-3333-3333-333333333333', 'my-hero-academia', 'Моя геройська академія', 'My Hero Academia', '僕のヒーローアカデミア', 'A superhero anime set in a world where people have superpowers called "Quirks".', 'https://example.com/my-hero-academia.jpg', 'Bones', 33445, 66778, 99001, 121314, 2016, 24, 'pg13', 'ongoing', 'tv', TRUE ),
  ( '44444444-4444-4444-4444-444444444444', 'demon-slayer', 'Вбивця демонів', 'Demon Slayer', '鬼滅の刃', 'A historical fantasy anime about a boy who becomes a demon slayer to avenge his family.', 'https://example.com/demon-slayer.jpg', 'ufotable', 44556, 77889, 112233, 141516, 2019, 26, 'r', 'finished', 'tv', FALSE );
  
--- INSERT EXAMPLES ---

INSERT INTO users(user_id, nickname, full_name, email) VALUES
    ( '00000000-0000-7000-8000-000000000001','BadBoy67','He Is Bad','badboy67@ukr.net' ),
    ( '00000000-0000-7000-8000-000000000002','GoodBoy34','He Is Good','goodboy34@gmail.com' ),
    ( '00000000-0000-7000-8000-000000000003','TheBestBoy911','He Is The Best','thebestboy911@something.example' );

--- INSERT EXAMPLES ---

INSERT INTO upcoming_episodes(anime_id, episode_name, episode_date) VALUES
  ('11111111-1111-1111-1111-111111111111', 'EP2', NOW() + INTERVAL '7 days'),
  ('11111111-6666-1111-2222-111119999999', 'EP3', CURRENT_DATE + INTERVAL '30 days' + TIME '12:00:00'),
  ('44444444-4444-4444-4444-444444444444', 'Infinity Castle Arc: Part 1', NOW() + INTERVAL '90 days'),
  ('33333333-3333-3333-3333-333333333333', 'The Final Battle Begins', CURRENT_DATE + INTERVAL '30 days' + TIME '17:30:00');

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

--- INSERT EXAMPLES ---

INSERT INTO sessions(
    user_id,
    refresh_token,
    device_type,
    device_name
) VALUES
    (
        '00000000-0000-7000-8000-000000000001',
        '1',
        'desktop',
        'Windows PC'
    ),
    (
        '00000000-0000-7000-8000-000000000002',
        '2',
        'mobile',
        'iPhone 15 Pro'
    ),
    (
        '00000000-0000-7000-8000-000000000003',
        '3',
        'mobile',
        'ZTE Nubia Red Magic 7S Pro Supernova Lords Mobile Limited Edition'
    );

--- INSERT EXAMPLES ---

INSERT INTO genres(anime_id, genre_type) VALUES
  ( '11111111-1111-1111-1111-111111111111', 'action' ),
  ( '44444444-4444-4444-4444-444444444444', 'adventure' ),
  ( '11111111-6666-1111-2222-111119999999', 'avant_garde' ),
  ( '33333333-3333-3333-3333-333333333333', 'boys_love' ),
  ( '11111111-1111-1111-1111-111111111111', 'comedy' ),
  ( '33333333-3333-3333-3333-333333333333', 'demons' );

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

 --- INSERT EXAMPLES ---

INSERT INTO comments(author_id, anime_id, grade, content) VALUES
    (
        '00000000-0000-7000-8000-000000000001', 
        '11111111-1111-1111-1111-111111111111', 
        -3, 
        'Example Comment 1'
    ),
    (
        '00000000-0000-7000-8000-000000000002', 
        '11111111-6666-1111-2222-111119999999', 
        0, 
        'Example Comment 2'
    ),
    (
        '00000000-0000-7000-8000-000000000003', 
        '33333333-3333-3333-3333-333333333333', 
        NULL, 
        'Example Comment 3'
    );
```