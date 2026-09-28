-- DDL for animes table

CREATE TYPE anime_format_enum AS ENUM ('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE anime_status_enum AS ENUM ('upcoming', 'ongoing', 'dropped', 'finished');
CREATE TYPE mpaa_rating_enum AS ENUM (
    'g',-- General Audiences (Без обмежень)
    'pg',      -- Parental Guidance Suggested (Рекомендовано перегляд з батьками)
    'pg13',   -- Parents Strongly Cautioned (Дітям до 13 років небажано)
    'r',       -- Restricted (До 17 років тільки з дорослими)
    'nc17'    -- No One 17 and Under Admitted (Категорично з 18 років)
  );

CREATE TABLE animes (
  anime_id UUID DEFAULT uuidv7(),
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
  year_released INT SMALLINT CHECK (year >= 1900),
  avg_episode_duration INT SMALLINT NOT NULL DEFAULT 0,
  age_restriction mpaa_rating_enum,
  anime_status anime_status_enum,
  anime_format anime_format_enum NOT NULL DEFAULT 'tv',
  available BOOLEAN NOT NULL DEFAULT TRUE,

  PRIMARY KEY (anime_id)
);

  CREATE INDEX inx_anime_slug ON animes(slug);
  CREATE INDEX inx_anime_active ON animes(anime_active);

-- //TEST

INSERT INTO animes (anime_id, slug, title_ua, title_en, title_original, description, cover_url, production_studio, mal_id, anilist_id, hikka_id, imdb_id, year, avg_episode_duration, pegi_age_restriction, anime_status, anime_format, anime_active) VALUES

('11111111-1111-1111-1111-111111111111', 'one-piece', 'Ван-Піс', 'One Piece', 'ワンピース', 'A long-running adventure anime about pirates searching for the ultimate treasure.', 'https://example.com/one-piece.jpg', 'Toei Animation', 55667, 88990, 223344, 151617, 1999, 24, 'pg13', 'ongoing', 'tv', TRUE),
('22222222-2222-2222-2222-222222222222', 'spy-x-family', 'Шпигунська родина', 'Spy x Family', 'スパイファミリー', 'A comedy-action anime about a spy who must build a fake family to complete his mission.', 'https://example.com/spy-x-family.jpg', 'WIT Studio', 22334, 55667, 88990, 101112, 2022, 23, 'pg13', 'ongoing', 'tv', TRUE),
('33333333-3333-3333-3333-333333333333', 'my-hero-academia', 'Моя геройська академія', 'My Hero Academia', '僕のヒーローアカデミア', 'A superhero anime set in a world where people have superpowers called "Quirks".', 'https://example.com/my-hero-academia.jpg', 'Bones', 33445, 66778, 99001, 121314, 2016, 24, 'pg13', 'ongoing', 'tv', TRUE),
('44444444-4444-4444-4444-444444444444', 'demon-slayer', 'Вбивця демонів', 'Demon Slayer', '鬼滅の刃', 'A historical fantasy anime about a boy who becomes a demon slayer to avenge his family.', 'https://example.com/demon-slayer.jpg', 'ufotable', 44556, 77889, 112233, 141516, 2019, 26, 'r', 'finished', 'tv', FALSE);