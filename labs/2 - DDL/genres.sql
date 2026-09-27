-- DDL for genres table

CREATE TYPE genre_type AS ENUM (
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

CREATE TABLE genres (
  genre_id UUID PRIMARY KEY DEFAULT UUIDv7(),
  genre_type genre_type NOT NULL UNIQUE
)

--TEST

INSERT INTO genres (genre_id, genre_type) VALUES
  (UUIDv7(), 'action'),
  (UUIDv7(), 'adventure'),
  (UUIDv7(), 'avant_garde'),
  (UUIDv7(), 'boys_love'),
  (UUIDv7(), 'comedy'),
  (UUIDv7(), 'demons'),