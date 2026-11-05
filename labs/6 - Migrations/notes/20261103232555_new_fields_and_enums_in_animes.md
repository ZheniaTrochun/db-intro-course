# 20261103232555_new_fields_and_enums_in_animes

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
![alt text](https://ucarecdn.com/81904937-e6d3-4554-a00c-64e78ad7c362/image3.png)
