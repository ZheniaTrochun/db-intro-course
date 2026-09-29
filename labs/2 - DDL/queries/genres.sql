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

--- INSERT EXAMPLES ---

INSERT INTO genres(anime_id, genre_type) VALUES
  ( '11111111-1111-1111-1111-111111111111', 'action' ),
  ( '44444444-4444-4444-4444-444444444444', 'adventure' ),
  ( '11111111-6666-1111-2222-111119999999', 'avant_garde' ),
  ( '33333333-3333-3333-3333-333333333333', 'boys_love' ),
  ( '11111111-1111-1111-1111-111111111111', 'comedy' ),
  ( '33333333-3333-3333-3333-333333333333', 'demons' );
