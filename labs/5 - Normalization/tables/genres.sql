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
