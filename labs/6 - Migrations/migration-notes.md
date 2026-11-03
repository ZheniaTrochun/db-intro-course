

# 1793734238-init-animes

Створено таблицю `animes` (модель `Anime`) з полями slug, title_ua, title_en, title_original, cover_url, production_studio, mal_id, anilist_id, hikka_id, imdb_id, year_released, avg_episode_duration, episode_count, age_restriction, anime_status, anime_format, available та enum-ами mpaa_rating_enum, anime_status_enum, anime_format_enum. Додано унікальний індекс на slug.

**Було:**
```prisma
// таблиця animes відсутня
```

**Стало:**
```prisma
enum MpaaRating {
  g
  pg
  pg13
  r
  nc17

  @@map("mpaa_rating_enum")
}

enum AnimeStatus {
  upcoming
  ongoing
  dropped
  finished

  @@map("anime_status_enum")
}

enum AnimeFormat {
  tv
  ova
  ona
  movie
  special
  music
  other

  @@map("anime_format_enum")
}

model Anime {
  animeId            String       @id @default(uuid()) @map("anime_id")
  slug               String       @unique
  titleUa            String       @default("") @map("title_ua")
  titleEn            String       @default("") @map("title_en")
  titleOriginal      String       @default("") @map("title_original")
  coverUrl           String?      @map("cover_url")
  productionStudio   String?      @map("production_studio")
  malId              Int?         @map("mal_id")
  anilistId          Int?         @map("anilist_id")
  hikkaId            String?      @map("hikka_id")
  imdbId             String?      @map("imdb_id")
  yearReleased       Int?         @map("year_released")
  avgEpisodeDuration Int          @default(0) @map("avg_episode_duration")
  episodeCount       Int          @default(0) @map("episode_count")
  ageRestriction     MpaaRating?  @map("age_restriction")
  animeStatus        AnimeStatus? @map("anime_status")
  animeFormat        AnimeFormat  @default(tv) @map("anime_format")
  available          Boolean      @default(true) @map("available")

  genres             Genre[]
  upcomingEpisodes   UpcomingEpisode[]

  @@index([available], map: "idx_anime_available")
  @@map("animes")
}
```


## Prisma Studio
![alt text](image.png)

# 1793735257-init-genres

Створено таблицю `genres` (модель `Genre`) з полями anime_id, genre_type, is_primary. Додано складений первинний ключ (anime_id, genre_type) та зовнішній ключ на animes(anime_id). Додано enum genre_type_enum.

**Було:**
```prisma
// таблиця genres відсутня
```

**Стало:**
```prisma
enum GenreType {
  action
  adventure
  avant_garde
  boys_love
  comedy
  demons
  drama
  ecchi
  fantasy
  girls_love
  gourmet
  harem
  hentai
  historical
  horror
  isekai
  josei
  kids
  magic
  martial_arts
  mecha
  military
  music
  mystery
  parody
  psychological
  romance
  samurai
  school
  sci_fi
  seinen
  shoujo
  shoujo_ai
  shounen
  shounen_ai
  slice_of_life
  space
  sports
  supernatural
  super_power
  suspense

  @@map("genre_type_enum")
}

model Genre {
  animeId   String     @map("anime_id") @db.Uuid
  genreType GenreType  @map("genre_type")
  isPrimary Boolean    @default(false) @map("is_primary")

  anime     Anime      @relation(fields: [animeId], references: [animeId])

  @@id([animeId, genreType])
  @@map("genres")
}
```


## Prisma Studio
![alt text](image-1.png)

# 1793735805-init-upcoming-episodes

Створено таблицю `upcoming_episodes` (модель `UpcomingEpisode`) з полями anime_id, episode_name, episode_date. Додано складений первинний ключ (anime_id, episode_name) та зовнішній ключ на animes(anime_id).

**Було:**
```prisma
// таблиця upcoming_episodes відсутня
```

**Стало:**
```prisma
model UpcomingEpisode {
  animeId     String   @map("anime_id") @db.Uuid
  episodeName String   @map("episode_name")
  episodeDate DateTime @default(now()) @map("episode_date")

  anime      Anime    @relation(fields: [animeId], references: [animeId])

  @@id([animeId, episodeName])
  @@map("upcoming_episodes")
}
```


## Prisma Studio
![alt text](image-2.png)

# 1793748355-new-fields-and-enums-in-animes

Додано значення `dropped` до enum `anime_status_enum`. В таблиці `animes` додано колонку `available` (BOOLEAN, default true) з індексом `idx_anime_available`. Видалено колонки `anime_description` та `is_exist`. Встановлено defaults для `title_ua`, `title_en`, `title_original` (''), `avg_episode_duration` та `episode_count` (0). Змінено тип `mal_id` та `anilist_id` з TEXT на INTEGER. Виправлено тип `anime_id` на UUID (додано `@db.Uuid`), щоб уникнути зміни первинного ключа.

**Було:**
```prisma
model Anime {
  animeId            String       @id @default(uuid()) @map("anime_id")
  slug               String       @unique
  titleUa            String       @map("title_ua")
  titleEn            String       @map("title_en")
  titleOriginal      String       @map("title_original")
  animeDescription   String       @default("") @map("anime_description")
  coverUrl           String?      @map("cover_url")
  productionStudio   String?      @map("production_studio")
  malId              String?      @map("mal_id")
  anilistId          String?      @map("anilist_id")
  hikkaId            String?      @map("hikka_id")
  imdbId             String?      @map("imdb_id")
  yearReleased       Int?         @map("year_released")
  avgEpisodeDuration Int          @map("avg_episode_duration")
  episodeCount       Int          @map("episode_count")
  ageRestriction     MpaaRating?  @map("age_restriction")
  animeStatus        AnimeStatus? @map("anime_status")
  animeFormat        AnimeFormat  @default(tv) @map("anime_format")
  isExist            Boolean      @default(false) @map("is_exist")

  genres             Genre[]
  upcomingEpisodes   UpcomingEpisode[]

  @@map("animes")
}

enum AnimeStatus {
  upcoming
  ongoing
  finished

  @@map("anime_status_enum")
}
```

**Стало:**
```prisma
model Anime {
  animeId            String       @id @default(uuid()) @map("anime_id") @db.Uuid
  slug               String       @unique
  titleUa            String       @default("") @map("title_ua")
  titleEn            String       @default("") @map("title_en")
  titleOriginal      String       @default("") @map("title_original")
  coverUrl           String?      @map("cover_url")
  productionStudio   String?      @map("production_studio")
  malId              Int?         @map("mal_id")
  anilistId          Int?         @map("anilist_id")
  hikkaId            String?      @map("hikka_id")
  imdbId             String?      @map("imdb_id")
  yearReleased       Int?         @map("year_released")
  avgEpisodeDuration Int          @default(0) @map("avg_episode_duration")
  episodeCount       Int          @default(0) @map("episode_count")
  ageRestriction     MpaaRating?  @map("age_restriction")
  animeStatus        AnimeStatus? @map("anime_status")
  animeFormat        AnimeFormat  @default(tv) @map("anime_format")
  available          Boolean      @default(true) @map("available")

  genres             Genre[]
  upcomingEpisodes   UpcomingEpisode[]

  @@index([available], map: "idx_anime_available")
  @@map("animes")
}

enum AnimeStatus {
  upcoming
  ongoing
  dropped
  finished

  @@map("anime_status_enum")
}
```


## Prisma Studio
![alt text](image-3.png)

# 1793749059-update-genres-map-and-enum

Додано мапінги `@map`/`@@map` для моделі `Genre` та enum `GenreType`. Додано значення `thriller` та `vampire` до enum `genre_type_enum`. Змінено зовнішній ключ `genres_anime_id_fkey` на `ON DELETE CASCADE`. Додано індекс `idx_genres_genre_type` на колонку `genre_type`.

**Було:**
```prisma
enum GenreType {
  action
  adventure
  avant_garde
  boys_love
  comedy
  demons
  drama
  ecchi
  fantasy
  girls_love
  gourmet
  harem
  hentai
  historical
  horror
  isekai
  josei
  kids
  magic
  martial_arts
  mecha
  military
  music
  mystery
  parody
  psychological
  romance
  samurai
  school
  sci_fi
  seinen
  shoujo
  shoujo_ai
  shounen
  shounen_ai
  slice_of_life
  space
  sports
  supernatural
  super_power
  suspense

  // @@map відсутній
}

model Genre {
  animeId   String
  genreType GenreType
  isPrimary Boolean   @default(false)

  anime     Anime     @relation(fields: [animeId], references: [animeId])

  @@id([animeId, genreType])
  // @@map та @map відсутні
}
```

**Стало:**
```prisma
enum GenreType {
  action
  adventure
  avant_garde
  boys_love
  comedy
  demons
  drama
  ecchi
  fantasy
  girls_love
  gourmet
  harem
  hentai
  historical
  horror
  isekai
  josei
  kids
  magic
  martial_arts
  mecha
  military
  music
  mystery
  parody
  psychological
  romance
  samurai
  school
  sci_fi
  seinen
  shoujo
  shoujo_ai
  shounen
  shounen_ai
  slice_of_life
  space
  sports
  supernatural
  super_power
  suspense
  thriller
  vampire

  @@map("genre_type_enum")
}

model Genre {
  animeId   String     @map("anime_id") @db.Uuid
  genreType GenreType  @map("genre_type")
  isPrimary Boolean    @default(false) @map("is_primary")

  anime     Anime      @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, genreType])
  @@index([genreType], map: "idx_genres_genre_type")
  @@map("genres")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://example.com)

