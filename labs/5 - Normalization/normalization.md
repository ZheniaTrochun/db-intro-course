# Звіт по нормалізації

## Початок лабораторної

### До

<details>
<summary>Поглянути код</summary>

```sql
-- users

CREATE TYPE public.user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE public.user_role_enum AS ENUM('user', 'admin');

CREATE TABLE IF NOT EXISTS public.users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT,
    social_networks TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'UTC',
    streak_start_date DATE,
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_user_status ON public.users(user_status);

-- animes

CREATE TYPE public.anime_format_enum AS ENUM('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE public.anime_status_enum AS ENUM('upcoming', 'ongoing', 'cancelled', 'finished');
CREATE TYPE public.mpaa_rating_enum AS ENUM('g', 'pg', 'pg13', 'r', 'nc17');

CREATE TABLE IF NOT EXISTS public.animes(
  anime_id UUID PRIMARY KEY DEFAULT uuidv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT NOT NULL DEFAULT '',
  title_en TEXT NOT NULL DEFAULT '',
  title_original TEXT NOT NULL DEFAULT '',
  anime_description TEXT NOT NULL DEFAULT '',
  cover_url TEXT NOT NULL DEFAULT '',
  production_studio TEXT NOT NULL DEFAULT '',
  mal_id BIGINT,
  anilist_id BIGINT,
  hikka_id TEXT,
  imdb_id TEXT,
  year_released SMALLINT CHECK(year_released >= 1900),
  avg_episode_duration SMALLINT NOT NULL DEFAULT 0 CHECK(avg_episode_duration >= 0),
  episodes_count SMALLINT NOT NULL DEFAULT 0 CHECK(episodes_count >= 0),
  age_restriction mpaa_rating_enum,
  anime_status anime_status_enum,
  anime_format anime_format_enum NOT NULL DEFAULT 'tv',
  available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_anime_available ON public.animes(available);

-- anime_list_units

CREATE TYPE public.anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE IF NOT EXISTS public.anime_list_units(
  user_id UUID NOT NULL,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  watched_episodes INT NOT NULL DEFAULT 0 CHECK(watched_episodes >= 0),
  repeat_times INT NOT NULL DEFAULT 0 CHECK(repeat_times >= 0),
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',
  grade SMALLINT CHECK(grade BETWEEN -5 AND 5),

  PRIMARY KEY(user_id, anime_id)
);

-- comments

CREATE TABLE IF NOT EXISTS public.comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_edited BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_comments_anime_created ON public.comments(anime_id, comment_id DESC);

-- episodes

CREATE TYPE public.episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE IF NOT EXISTS public.episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  localization_studio TEXT NOT NULL DEFAULT '',
  localization_type episode_localization_type_enum
);

CREATE INDEX IF NOT EXISTS idx_episodes_anime_id ON public.episodes(anime_id);

-- genres

CREATE TYPE public.genre_type_enum AS ENUM(
    'action','adventure',
    'avant_garde','award_winning',
    'boys_love','comedy',
    'drama','fantasy',
    'girls_love','gourmet',
    'horror','mystery',
    'romance','sci-fi',
    'slice_of_life',
    'sports','supernatural',
    'suspense','ecchi',
    'erotica','hentai',
    'adult_cast','anthropomorphic',
    'cgdct','childcare',
    'combat_sports','crossdressing',
    'delinquents','detective',
    'educational','gag_humor',
    'gore','harem',
    'high_stakes_game','historical',
    'idols_female','idols_male',
    'isekai','iyashikei',
    'love_polygon','love_status_quo',
    'fantasy_sex_shift','mahou_shoujo',
    'martial_arts','mecha',
    'medical','military',
    'music','mythology',
    'organized_crime',
    'otaku_culture','parody',
    'performing_arts','pets',
    'psychological','racing',
    'reincarnation','reverse_harem',
    'samurai','school',
    'showbiz','space',
    'strategy_game','super_power',
    'survival','team_sports',
    'time_travel','urban_fantasy',
    'vampire','video_game',
    'villainess','visual_arts',
    'workplace','josei',
    'kids','seinen',
    'shoujo','shounen'
);

CREATE TABLE IF NOT EXISTS public.genres(
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  genre_type genre_type_enum NOT NULL,

  PRIMARY KEY(anime_id, genre_type)
);

CREATE INDEX IF NOT EXISTS idx_genre_type ON public.genres(genre_type);

-- sessions

CREATE TABLE IF NOT EXISTS public.sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    refresh_token BYTEA NOT NULL UNIQUE CHECK(length(refresh_token) = 96),
    expire_time TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '1 year',
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);

-- upcoming_episodes

CREATE TABLE IF NOT EXISTS public.upcoming_episodes(
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  PRIMARY KEY(anime_id, episode_name)
);

CREATE INDEX IF NOT EXISTS idx_upcoming_episode_date ON public.upcoming_episodes(episode_date ASC);
```

</details>

### Залежності

**anime_list_units:**
- (user_id, anime_id) -> watched_episodes, repeat_times, started_watching, list_unit_status, grade

**animes:**
- anime_id -> slug, title_ua, title_en, title_original, anime_description, cover_url, production_studio, mal_id, anilist_id, hikka_id, imdb_id, year_released, avg_episode_duration, episodes_count, age_restriction, anime_status, anime_format, available

**comments:**
- comment_id -> author_id, anime_id, content, created_at, is_edited

**episodes:**
- episode_id -> anime_id, source_url, episode_name, localization_studio, localization_type

**genres:**
- (anime_id, genre_type)

**sessions:**
- session_id -> user_id, refresh_token, expire_time, device_type, device_name, os, browser, user_agent, user_location, ip_address
- user_agent -> browser

*Примітка: Також може здатися, що локація користувача залежна від його IP, але в конкретно нашому випадку - це не так.
Існує декілька можливих способів дізнатися локацію користувача (як от IP адреса, GPS, часовий пояс і тд) і ми залишаємо
вибір визначати спосіб власне Backend/Frontend сервісам, тож визначена локація може відрізнятися від того, що показує IP адреса
(головною причиною через те що IP належить провайдерам). Тим часом агент користувача є ледь не єдиним способом дізнатися назву браузера*

**upcoming_episodes:**
- (anime_id, episode_name) -> episode_date

**users:**
- user_id -> nickname, full_name, email, google_id, bio, password_hash, avatar_url, social_networks, max_streak, timezone, streak_start_date, last_watch_date, profile_frame_url, profile_background_url, user_role, user_status, created_at, updated_at

### Аудит

1. **1NF проблема:** єдиною проблемою є тип поля `social_networks` таблиці `users`, оскільки він має тип даних масиву.
2. **2NF проблема:** тут є лише три таблиці з складеними ключем.
    Двоє з них - асоціативна та проміжна, тож використання складених ключів виправдана, а от `upcoming_episodes` не є асоціативним.
    Саме по собі наявність складеного PK не порушує 2NF, але ускладнює подальшу діагностику. Тому, краще вжити заходів,
    щоб уникнути 2NF проблем у майбутньому.
3. **3NF проблема:** у `sessions` є поле (`browser`), яке залежить від `user_agent`.

### Рішення

- Рішення **проблеми №1** полягає у створені окремої таблиці, яка буде мати зв'язок багато-до-одного з таблицею users.
- Щоб вирішити **проблему №2** слід створити окремий ключ (автоінкрементуючий), а наявну пару перетворити в UNIQUE.
- Ми вирішили забрати `user_agent` як поле, оскільки вона не несе ніякої смислової інформації для пересічного користувача. Це має вирішити **проблему №3**.

### Результат

- Було створено таблицю `user_links` з полями `user_link_id`, `user_id`, `user_link_url`.
    Додатково є поле `provider` з визначеними назвами платформ на які посилається `user_link_url`.
- Таблиця `upcoming_episodes` отримало нове поле `upcoming_episode_id`, яке і стало новим ключем.
- `user_agent` більше немає у таблиці `sessions`.

```sql
BEGIN;
ALTER TABLE public.users DROP COLUMN social_networks;
ALTER TABLE public.sessions DROP COLUMN user_agent;
ALTER TABLE public.upcoming_episodes DROP CONSTRAINT upcoming_episodes_pkey;
ALTER TABLE public.upcoming_episodes ADD COLUMN upcoming_episode_id UUID NOT NULL DEFAULT uuidv7();
ALTER TABLE public.upcoming_episodes ADD PRIMARY KEY (upcoming_episode_id);

CREATE TYPE public.provider_enum AS ENUM(
    'github', 'facebook', 'instagram', 'telegram',
    'linkedin', 'email', 'youtube', 'reddit', 'twitter'
);

CREATE TABLE IF NOT EXISTS public.user_links(
    user_link_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    user_link_url TEXT NOT NULL,
    provider provider_enum NOT NULL,

    UNIQUE(user_id, user_link_url)
);

COMMIT;
```
*P.S.: Проігноровано інші паралельні зміни зроблені поза межами лабораторної роботи*

### Після

<details>
<summary>Поглянути код</summary>

```sql
-- users

CREATE TYPE public.user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE public.user_role_enum AS ENUM('user', 'admin');

CREATE TABLE IF NOT EXISTS public.users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT NOT NULL DEFAULT '',
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'Europe/Kyiv',
    streak_start_date DATE,
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(user_status);
CREATE UNIQUE INDEX idx_users_unique_lower_nickname ON public.users(lower(nickname));
CREATE UNIQUE INDEX idx_users_unique_lower_email ON public.users(lower(email));

-- animes

CREATE TYPE public.anime_format_enum AS ENUM('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE public.anime_status_enum AS ENUM('upcoming', 'ongoing', 'cancelled', 'finished');
CREATE TYPE public.mpaa_rating_enum AS ENUM('g', 'pg', 'pg13', 'r', 'nc17');

CREATE TABLE IF NOT EXISTS public.animes(
  anime_id UUID PRIMARY KEY DEFAULT uuidv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT NOT NULL DEFAULT '',
  title_en TEXT NOT NULL DEFAULT '',
  title_original TEXT NOT NULL DEFAULT '',
  anime_description TEXT NOT NULL DEFAULT '',
  cover_url TEXT NOT NULL DEFAULT '',
  production_studio TEXT NOT NULL DEFAULT '',
  mal_id BIGINT UNIQUE,
  anilist_id BIGINT UNIQUE,
  hikka_id TEXT UNIQUE,
  imdb_id TEXT UNIQUE,
  year_released SMALLINT CHECK(year_released >= 1900),
  avg_episode_duration SMALLINT NOT NULL DEFAULT 0 CHECK(avg_episode_duration >= 0),
  episodes_count SMALLINT NOT NULL DEFAULT 0 CHECK(episodes_count >= 0),
  age_restriction mpaa_rating_enum,
  anime_status anime_status_enum,
  anime_format anime_format_enum NOT NULL DEFAULT 'tv',
  available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_animes_available ON public.animes(available);

-- anime_list_units

CREATE TYPE public.anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE IF NOT EXISTS public.anime_list_units(
  user_id UUID NOT NULL,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  watched_episodes INT NOT NULL DEFAULT 0 CHECK(watched_episodes >= 0),
  repeat_times INT NOT NULL DEFAULT 0 CHECK(repeat_times >= 0),
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',
  grade SMALLINT CHECK(grade BETWEEN -5 AND 5),

  PRIMARY KEY(user_id, anime_id)
);

-- comments

CREATE TABLE IF NOT EXISTS public.comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_edited BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_comments_anime_created ON public.comments(anime_id, comment_id DESC);

-- episodes

CREATE TYPE public.episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE IF NOT EXISTS public.episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL UNIQUE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  localization_studio TEXT NOT NULL DEFAULT '',
  localization_type episode_localization_type_enum
);

CREATE INDEX IF NOT EXISTS idx_episodes_anime_id ON public.episodes(anime_id);

-- genres

CREATE TYPE public.genre_type_enum AS ENUM(
    'action','adventure',
    'avant_garde','award_winning',
    'boys_love','comedy',
    'drama','fantasy',
    'girls_love','gourmet',
    'horror','mystery',
    'romance','sci_fi',
    'slice_of_life',
    'sports','supernatural',
    'suspense','ecchi',
    'erotica','hentai',
    'adult_cast','anthropomorphic',
    'cgdct','childcare',
    'combat_sports','crossdressing',
    'delinquents','detective',
    'educational','gag_humor',
    'gore','harem',
    'high_stakes_game','historical',
    'idols_female','idols_male',
    'isekai','iyashikei',
    'love_polygon','love_status_quo',
    'fantasy_sex_shift','mahou_shoujo',
    'martial_arts','mecha',
    'medical','military',
    'music','mythology',
    'organized_crime',
    'otaku_culture','parody',
    'performing_arts','pets',
    'psychological','racing',
    'reincarnation','reverse_harem',
    'samurai','school',
    'showbiz','space',
    'strategy_game','super_power',
    'survival','team_sports',
    'time_travel','urban_fantasy',
    'vampire','video_game',
    'villainess','visual_arts',
    'workplace','josei',
    'kids','seinen',
    'shoujo','shounen'
);

CREATE TABLE IF NOT EXISTS public.genres(
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  genre_type genre_type_enum NOT NULL,

  PRIMARY KEY(anime_id, genre_type)
);

CREATE INDEX IF NOT EXISTS idx_genres_type ON public.genres(genre_type);

-- sessions

CREATE TABLE IF NOT EXISTS public.sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    refresh_token BYTEA NOT NULL UNIQUE CHECK(length(refresh_token) = 96),
    expire_time TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '180 days',
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expire_time ON public.sessions(expire_time ASC);

-- upcoming_episodes

CREATE TABLE upcoming_episodes(
  upcoming_episode_id UUID PRIMARY KEY DEFAULT uuidv7(),
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL DEFAULT '',
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(anime_id, episode_name)
);

-- user_links
CREATE TYPE public.provider_enum AS ENUM(
    'github', 
    'facebook', 
    'instagram', 
    'telegram', 
    'linkedin', 
    'email', 
    'youtube', 
    'reddit', 
    'twitter'
);

CREATE TABLE IF NOT EXISTS public.user_links(
    user_link_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    user_link_url TEXT NOT NULL,
    provider provider_enum NOT NULL,

    UNIQUE(user_id, user_link_url)
);
```

</details>

*P.S: Паралельно велися інші оптимізації іншою частиною команди, тому тут є інші зміни окрім вище описаних*

## Після оновлення

### Залежності

**anime_list_units:**
- (user_id, anime_id) -> watched_episodes, repeat_times, started_watching, list_unit_status, grade

**animes:**
- anime_id -> slug, title_ua, title_en, title_original, anime_description, cover_url, production_studio, mal_id, anilist_id, hikka_id, imdb_id, year_released, avg_episode_duration, episodes_count, age_restriction, anime_status, anime_format, available

**comments:**
- comment_id -> author_id, anime_id, content, created_at, is_edited

**episodes:**
- episode_id -> anime_id, source_url, episode_name, localization_studio, localization_type

**genres:**
- (anime_id, genre_type)

**sessions:**
- session_id -> user_id, refresh_token, expire_time, device_type, device_name, os, browser, user_location, ip_address

**upcoming_episodes:**
- upcoming_episode_id -> anime_id, episode_name, episode_date

**user_links:**
- user_link_id -> user_id, user_link_url, provider
- user_link_url -> provider

**users:**
- user_id -> nickname, full_name, email, google_id, bio, password_hash, avatar_url, max_streak, timezone, streak_start_date, last_watch_date, profile_frame_url, profile_background_url, user_role, user_status, created_at, updated_at

### Аудит

1. **3NF проблема:** виходить тепер `provider` залежить від `user_link_url` у таблиці `user_links`

### Рішення

- Видалити поле `provider` з `user_links`, визначати соцмережу автоматично на Backend за допомогою доменного імені.

### Результат

- `provider` більше немає у таблиці `user_links`.

```sql
ALTER TABLE public.user_links DROP COLUMN provider;
```

### Після

<details>
<summary>Поглянути код</summary>

```sql
-- users

CREATE TYPE public.user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE public.user_role_enum AS ENUM('user', 'admin');

CREATE TABLE IF NOT EXISTS public.users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT NOT NULL DEFAULT '',
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'Europe/Kyiv',
    streak_start_date DATE,
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(user_status);
CREATE UNIQUE INDEX idx_users_unique_lower_nickname ON public.users(lower(nickname));
CREATE UNIQUE INDEX idx_users_unique_lower_email ON public.users(lower(email));

-- animes

CREATE TYPE public.anime_format_enum AS ENUM('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE public.anime_status_enum AS ENUM('upcoming', 'ongoing', 'cancelled', 'finished');
CREATE TYPE public.mpaa_rating_enum AS ENUM('g', 'pg', 'pg13', 'r', 'nc17');

CREATE TABLE IF NOT EXISTS public.animes(
  anime_id UUID PRIMARY KEY DEFAULT uuidv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT NOT NULL DEFAULT '',
  title_en TEXT NOT NULL DEFAULT '',
  title_original TEXT NOT NULL DEFAULT '',
  anime_description TEXT NOT NULL DEFAULT '',
  cover_url TEXT NOT NULL DEFAULT '',
  production_studio TEXT NOT NULL DEFAULT '',
  mal_id BIGINT UNIQUE,
  anilist_id BIGINT UNIQUE,
  hikka_id TEXT UNIQUE,
  imdb_id TEXT UNIQUE,
  year_released SMALLINT CHECK(year_released >= 1900),
  avg_episode_duration SMALLINT NOT NULL DEFAULT 0 CHECK(avg_episode_duration >= 0),
  episodes_count SMALLINT NOT NULL DEFAULT 0 CHECK(episodes_count >= 0),
  age_restriction mpaa_rating_enum,
  anime_status anime_status_enum,
  anime_format anime_format_enum NOT NULL DEFAULT 'tv',
  available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_animes_available ON public.animes(available);

-- anime_list_units

CREATE TYPE public.anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE IF NOT EXISTS public.anime_list_units(
  user_id UUID NOT NULL,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  watched_episodes INT NOT NULL DEFAULT 0 CHECK(watched_episodes >= 0),
  repeat_times INT NOT NULL DEFAULT 0 CHECK(repeat_times >= 0),
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',
  grade SMALLINT CHECK(grade BETWEEN -5 AND 5),

  PRIMARY KEY(user_id, anime_id)
);

-- comments

CREATE TABLE IF NOT EXISTS public.comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_edited BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_comments_anime_created ON public.comments(anime_id, comment_id DESC);

-- episodes

CREATE TYPE public.episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE IF NOT EXISTS public.episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL UNIQUE,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  localization_studio TEXT NOT NULL DEFAULT '',
  localization_type episode_localization_type_enum
);

CREATE INDEX IF NOT EXISTS idx_episodes_anime_id ON public.episodes(anime_id);

-- genres

CREATE TYPE public.genre_type_enum AS ENUM(
    'action','adventure',
    'avant_garde','award_winning',
    'boys_love','comedy',
    'drama','fantasy',
    'girls_love','gourmet',
    'horror','mystery',
    'romance','sci_fi',
    'slice_of_life',
    'sports','supernatural',
    'suspense','ecchi',
    'erotica','hentai',
    'adult_cast','anthropomorphic',
    'cgdct','childcare',
    'combat_sports','crossdressing',
    'delinquents','detective',
    'educational','gag_humor',
    'gore','harem',
    'high_stakes_game','historical',
    'idols_female','idols_male',
    'isekai','iyashikei',
    'love_polygon','love_status_quo',
    'fantasy_sex_shift','mahou_shoujo',
    'martial_arts','mecha',
    'medical','military',
    'music','mythology',
    'organized_crime',
    'otaku_culture','parody',
    'performing_arts','pets',
    'psychological','racing',
    'reincarnation','reverse_harem',
    'samurai','school',
    'showbiz','space',
    'strategy_game','super_power',
    'survival','team_sports',
    'time_travel','urban_fantasy',
    'vampire','video_game',
    'villainess','visual_arts',
    'workplace','josei',
    'kids','seinen',
    'shoujo','shounen'
);

CREATE TABLE IF NOT EXISTS public.genres(
  anime_id UUID NOT NULL REFERENCES public.animes(anime_id) ON DELETE CASCADE,
  genre_type genre_type_enum NOT NULL,

  PRIMARY KEY(anime_id, genre_type)
);

CREATE INDEX IF NOT EXISTS idx_genres_type ON public.genres(genre_type);

-- sessions

CREATE TABLE IF NOT EXISTS public.sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    refresh_token BYTEA NOT NULL UNIQUE CHECK(length(refresh_token) = 96),
    expire_time TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '180 days',
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expire_time ON public.sessions(expire_time ASC);

-- upcoming_episodes

CREATE TABLE upcoming_episodes(
  upcoming_episode_id UUID PRIMARY KEY DEFAULT uuidv7(),
  anime_id UUID REFERENCES animes(anime_id) ON DELETE CASCADE,
  episode_name TEXT NOT NULL DEFAULT '',
  episode_date TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(anime_id, episode_name)
);

-- user_links
CREATE TABLE IF NOT EXISTS public.user_links(
    user_link_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    user_link_url TEXT NOT NULL,

    UNIQUE(user_id, user_link_url)
);
```

</details>

## Після оновлення, №2

### Залежності

**anime_list_units:**
- (user_id, anime_id) -> watched_episodes, repeat_times, started_watching, list_unit_status, grade

**animes:**
- anime_id -> slug, title_ua, title_en, title_original, anime_description, cover_url, production_studio, mal_id, anilist_id, hikka_id, imdb_id, year_released, avg_episode_duration, episodes_count, age_restriction, anime_status, anime_format, available

**comments:**
- comment_id -> author_id, anime_id, content, created_at, is_edited

**episodes:**
- episode_id -> anime_id, source_url, episode_name, localization_studio, localization_type

**genres:**
- (anime_id, genre_type)

**sessions:**
- session_id -> user_id, refresh_token, expire_time, device_type, device_name, os, browser, user_location, ip_address

**upcoming_episodes:**
- upcoming_episode_id -> anime_id, episode_name, episode_date

**user_links:**
- user_link_id -> user_id, user_link_url

**users:**
- user_id -> nickname, full_name, email, google_id, bio, password_hash, avatar_url, max_streak, timezone, streak_start_date, last_watch_date, profile_frame_url, profile_background_url, user_role, user_status, created_at, updated_at

### Аудит

Проблем не виявлено
