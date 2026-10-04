CREATE TYPE anime_format_enum AS ENUM('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');
CREATE TYPE anime_status_enum AS ENUM('upcoming', 'ongoing', 'cancelled', 'finished');
CREATE TYPE mpaa_rating_enum AS ENUM('g', 'pg', 'pg13', 'r', 'nc17');

CREATE TABLE animes(
  anime_id UUID PRIMARY KEY DEFAULT uuidv7(),
  slug TEXT NOT NULL UNIQUE,
  title_ua TEXT NOT NULL DEFAULT '',
  title_en TEXT NOT NULL DEFAULT '',
  title_original TEXT NOT NULL DEFAULT '',
  anime_description TEXT NOT NULL DEFAULT '',
  cover_url TEXT,
  production_studio TEXT,
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

CREATE INDEX idx_anime_available ON animes(available);

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
  episodes_count,
  age_restriction,
  anime_status, anime_format, available
) VALUES
  ( '11111111-1111-1111-1111-111111111111', 'one-piece', 'Ван-Піс', 'One Piece', 'ワンピース', 'A long-running adventure anime about pirates searching for the ultimate treasure.', 'https://example.com/one-piece.jpg', 'Toei Animation', 55667, 88990, 223344, 151617, 1999, 24, 100, 'pg13', 'ongoing', 'tv', TRUE ),
  ( '11111111-6666-1111-2222-111119999999', 'spy-x-family', 'Шпигунська родина', 'Spy x Family', 'スパイファミリー', 'A comedy-action anime about a spy who must build a fake family to complete his mission.', 'https://example.com/spy-x-family.jpg', 'WIT Studio', 22334, 55667, 88990, 101112, 2022, 23, 50, 'pg13', 'ongoing', 'tv', TRUE ),
  ( '33333333-3333-3333-3333-333333333333', 'my-hero-academia', 'Моя геройська академія', 'My Hero Academia', '僕のヒーローアカデミア', 'A superhero anime set in a world where people have superpowers called "Quirks".', 'https://example.com/my-hero-academia.jpg', 'Bones', 33445, 66778, 99001, 121314, 2016, 24, 150, 'pg13', 'ongoing', 'tv', TRUE ),
  ( '44444444-4444-4444-4444-444444444444', 'demon-slayer', 'Вбивця демонів', 'Demon Slayer', '鬼滅の刃', 'A historical fantasy anime about a boy who becomes a demon slayer to avenge his family.', 'https://example.com/demon-slayer.jpg', 'ufotable', 44556, 77889, 112233, 141516, 2019, 26, 75, 'r', 'finished', 'tv', FALSE );
