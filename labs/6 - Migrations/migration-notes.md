

# 20261103192302_init_users

Створено таблицю `users` (модель `User`) з полями user_id (UUID, default `uuidv7()`), nickname, full_name, email, google_id, bio, password_hash, avatar_url, social_networks, max_streak, timezone, last_watch_date, profile_frame_url, profile_background_url, user_status, crated_at, updated_at та enum `user_status_enum`. Додано унікальні індекси на nickname, email та google_id, а також індекси `idx_user_status` і `idx_nickname`.

**Було:**
```prisma
// таблиця users відсутня
```

**Стало:**
```prisma
enum UserStatusEnum {
  admin
  banned
  deactivated

  @@map("user_status_enum")
}

model User {
  userId               String          @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String          @unique @db.VarChar(30)
  fullName             String          @map("full_name") @db.VarChar(100)
  email                String          @unique
  googleId             String?         @unique @map("google_id")
  bio                  String          @default("")
  passwordHash         String?         @map("password_hash")
  avatarUrl            String?         @map("avatar_url")
  socialNetworks       String[]        @default([]) @map("social_networks")
  maxStreak            Int             @default(0) @map("max_streak")
  timezone             String          @default("UTC")
  lastWatchDate        DateTime?       @map("last_watch_date") @db.Date
  profileFrameUrl      String?         @map("profile_frame_url")
  profileBackgroundUrl String?         @map("profile_background_url")
  userStatus           UserStatusEnum? @map("user_status")
  cratedAt             DateTime        @default(now()) @map("crated_at") @db.Timestamp(6)
  updatedAt            DateTime        @default(now()) @map("updated_at") @db.Timestamp(6)

  @@index([userStatus], map: "idx_user_status")
  @@index([nickname], map: "idx_nickname")
  @@map("users")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/3b745783-babb-4beb-a35b-39b7cb1ebbb8/noroot.png)


# 20261103193038_init_animes

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
  cancelled
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


# 20261103193846_init_comments

Створено таблицю `comments` (модель `Comment`) з полями comment_id (BIGSERIAL), author_id, anime_id, grade, content, created_at. Додано індекс `idx_comments_anime_id` на колонку `anime_id` та зовнішні ключі на `users(user_id)` і `animes(anime_id)` з `ON DELETE CASCADE`. У моделі `User` та `Anime` додано зворотні зв'язки `comments`.

**Було:**
```prisma
// таблиця comments відсутня
```

**Стало:**
```prisma
model Comment {
  commentId BigInt   @id @default(autoincrement()) @map("comment_id")
  authorId  String   @map("author_id") @db.Uuid
  animeId   String   @map("anime_id") @db.Uuid
  grade     Int?     @db.SmallInt
  content   String
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamp(6)

  author User  @relation(fields: [authorId], references: [userId], onDelete: Cascade)
  anime  Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_comments_anime_id")
  @@map("comments")
}

// додано у моделі User та Anime
model User {
  // ...
  comments Comment[]
}

model Anime {
  // ...
  comments Comment[]
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/b043c2c3-b59c-47bc-bc0d-c7327cf8a629/noroot.png)


# 20261103194737_init_genres

Створено таблицю `genres` (модель `Genre`) з полями anime_id, genre_type. Додано складений первинний ключ (anime_id, genre_type) та зовнішній ключ на animes(anime_id). Додано enum genre_type_enum.

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


# 20261103195645_init_upcoming_episodes

Створено таблицю `upcoming_episodes` (модель `UpcomingEpisode`) з полями upcoming_episode_id, anime_id, episode_name, episode_date. Додано сурогатний первинний ключ (upcoming_episode_id), унікальний ключ (anime_id, episode_name) та зовнішній ключ на animes(anime_id).

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


# 20261103200712_init_anime_list_units

Створено таблицю anime_list_units
з рядками grade, watched_episodes, started_watching, anime_id, user_id, list_unit_status

**Було:**
```prisma
```

**Стало:**
```prisma
enum AnimeListUnitStatus {
  finished
  watching
  delayed
  dropped

  @@map("anime_list_unit_status_enum")
}

model AnimeListUnit {
  userId String @map("user_id") @db.Uuid
  animeId String @map("anime_id") @db.Uuid
  watchedEpisodes Int @default(0) @map("watched_episodes")
  startedWatching DateTime @default(dbgenerated("(now())::date")) @map("started_watching") @db.Date
  listUnitStatus AnimeListUnitStatus @default(watching) @map("list_unit_status")
  grade Int?

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/27894ed1-e876-4568-91f8-36efb6c97aeb/-/preview/315x236/)


# 20261103200936_init_episodes

Створено таблицю episodes
з рядками episode_id, localization_type, localization_studio, episode_name, source_url, anime_id

**Було:**
```prisma
```

**Стало:**
```prisma
model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType String? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/33daf6d2-1b56-40bd-b0d0-bcdbb0188ab9/-/preview/301x299/)


# 20261103201113_init_sessions

Створено таблицю sessions
з рядками refresh_token, session_id, user_agent, user_location, browser, os, device_name, device_type, ip_address, expire_time, user_id

**Було:**
```prisma
```

**Стало:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet
  userAgent String? @map("user_agent")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@map("sessions")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/4eaa039f-29f5-40b7-b29a-8d847bf6cd2b/-/preview/345x573/)


# 20261103201850_new_repeat_times_field_for_list_units

Змінено таблицю anime_list_units
шляхом додавання рядка repeat_times

**Було:**
```prisma
enum AnimeListUnitStatus {
  finished
  watching
  delayed
  dropped

  @@map("anime_list_unit_status_enum")
}

model AnimeListUnit {
  userId String @map("user_id") @db.Uuid
  animeId String @map("anime_id") @db.Uuid
  watchedEpisodes Int @default(0) @map("watched_episodes")
  startedWatching DateTime @default(dbgenerated("(now())::date")) @map("started_watching") @db.Date
  listUnitStatus AnimeListUnitStatus @default(watching) @map("list_unit_status")
  grade Int?

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```

**Стало:**
```prisma
enum AnimeListUnitStatus {
  finished
  watching
  delayed
  dropped

  @@map("anime_list_unit_status_enum")
}

model AnimeListUnit {
  userId String @map("user_id") @db.Uuid
  animeId String @map("anime_id") @db.Uuid
  watchedEpisodes Int @default(0) @map("watched_episodes")
  repeatTimes Int @default(0) @map("repeat_times")
  startedWatching DateTime @default(dbgenerated("(now())::date")) @map("started_watching") @db.Date
  listUnitStatus AnimeListUnitStatus @default(watching) @map("list_unit_status")
  grade Int?

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/cd750aec-4d2d-4d45-a514-b1d5a71a0706/-/preview/455x391/)


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
![alt text](image-3.png)


# 20261103233739_update_genres_map_and_enum

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
![alt text](image-4.png)


# 20261103235221_new_index_upcoming_episodes

Додано мапінги `@map`/`@@map` для моделі `UpcomingEpisode`. Додано індекс `idx_upcoming_episodes_date` на колонку `episode_date`. Змінено зовнішній ключ `upcoming_episodes_anime_id_fkey` на `ON DELETE CASCADE`.

**Було:**
```prisma
model UpcomingEpisode {
  animeId     String
  episodeName String
  episodeDate DateTime @default(now())

  anime      Anime    @relation(fields: [animeId], references: [animeId])

  @@id([animeId, episodeName])
  // @@map та @map відсутні
}
```

**Стало:**
```prisma
model UpcomingEpisode {
  animeId     String   @map("anime_id") @db.Uuid
  episodeName String   @map("episode_name")
  episodeDate DateTime @default(now()) @map("episode_date")

  anime      Anime    @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, episodeName])
  @@index([episodeDate], map: "idx_upcoming_episodes_date")
  @@map("upcoming_episodes")
}
```


## Prisma Studio
![alt text](image-6.png)


# 20261104081400_list_units_grade_field_to_smallint

Змінено таблицю anime_list_units
шляхом зміни рядка grade
так щоб у базі даних він був типу SmallInt.

**Було:**
```prisma
enum AnimeListUnitStatus {
  finished
  watching
  delayed
  dropped

  @@map("anime_list_unit_status_enum")
}

model AnimeListUnit {
  userId String @map("user_id") @db.Uuid
  animeId String @map("anime_id") @db.Uuid
  watchedEpisodes Int @default(0) @map("watched_episodes")
  repeatTimes Int @default(0) @map("repeat_times")
  startedWatching DateTime @default(dbgenerated("(now())::date")) @map("started_watching") @db.Date
  listUnitStatus AnimeListUnitStatus @default(watching) @map("list_unit_status")
  grade Int?

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```

**Стало:**
```prisma
enum AnimeListUnitStatus {
  finished
  watching
  delayed
  dropped

  @@map("anime_list_unit_status_enum")
}

model AnimeListUnit {
  userId String @map("user_id") @db.Uuid
  animeId String @map("anime_id") @db.Uuid
  watchedEpisodes Int @default(0) @map("watched_episodes")
  repeatTimes Int @default(0) @map("repeat_times")
  startedWatching DateTime @default(dbgenerated("(now())::date")) @map("started_watching") @db.Date
  listUnitStatus AnimeListUnitStatus @default(watching) @map("list_unit_status")
  grade Int? @db.SmallInt

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/43451049-16fb-48fb-a008-bda5cbdc81cf/-/preview/509x428/)


# 20261104081603_source_url_made_unique_episodes

Змінено таблицю episodes
шляхом додавання Unique
на поле source_url.

**Було:**
```prisma
model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType String? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```

**Стало:**
```prisma
model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @unique @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType String? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/c71a8523-86f2-4a87-8eb7-3cc0e48d18dc/20261104104450_hyprshot.png)


# 20261104081749_sessions_expire_time_new_index

Змінено таблицю sessions
шляхом додавання індексу на рядок expire_time.

**Було:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet
  userAgent String? @map("user_agent")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@map("sessions")
}
```

**Стало:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet
  userAgent String? @map("user_agent")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@index([expireTime(sort: Asc)], map: "idx_sessions_expire_time")
  @@map("sessions")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/b5e0d7d5-697a-4a87-a900-466d12437905/20261104105250_hyprshot.png)


# 20261104081855_sessions_removed_user_agent_field

Змінено таблицю sessions
шляхом видалення рядка user_agent.

**Було:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet
  userAgent String? @map("user_agent")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@index([expireTime(sort: Asc)], map: "idx_sessions_expire_time")
  @@map("sessions")
}
```

**Стало:**
```prisma
model Session {
  sessionId BigInt @id @default(autoincrement()) @map("session_id")
  userId String @map("user_id") @db.Uuid
  refreshToken Bytes @unique @map("refresh_token")
  expireTime DateTime @default(dbgenerated("(now() + '180 days'::interval)")) @map("expire_time") @db.Timestamptz(6)
  deviceType String? @map("device_type")
  deviceName String? @map("device_name")
  os String?
  browser String?
  userLocation String? @map("user_location")
  ipAddress String? @map("ip_address") @db.Inet

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@index([userId], map: "idx_sessions_user_id")
  @@index([expireTime(sort: Asc)], map: "idx_sessions_expire_time")
  @@map("sessions")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/6b415495-991f-4dd7-ac16-527f34c296b9/20261104105038_hyprshot.png)


# 20261104082005_episodes_localization_type_new_enum

Створено/змінено таблицю episodes
шляхом зміни рядка localization_type
так щоб його значення було прив'язане до новоствореного enum.

**Було:**
```prisma
model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @unique @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType String? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```

**Стало:**
```prisma
enum EpisodeLocalizationType {
  sub
  dub

  @@map("episode_localization_type_enum")
}

model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @unique @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType EpisodeLocalizationType? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/0dd81694-7bd4-4555-b1b9-fc032277c7c0/20261104104742_hyprshot.png)


# 20261104083519_users_new_fields_and_enums

Змінено таблицю `users`. Створено enum `user_role_enum` (user, admin) та колонку `user_role` (default `user`), у яку перенесено користувачів зі статусом `admin`. Enum `user_status_enum` перебудовано: значення `admin` замінено на `active`, а колонку `user_status` зроблено `NOT NULL` з default `active` (існуючі `admin` та `NULL` перетворено на `active`). Додано колонку `streak_start_date`. Колонку `crated_at` перейменовано на `created_at`, а `created_at` та `updated_at` змінено на `TIMESTAMPTZ(6)`. Видалено індекс `idx_nickname`. Додано `CHECK`-обмеження `users_max_streak_check` та `check_user_auth_method` (потрібен `password_hash` або `google_id`), які Prisma не підтримує в схемі, тому вони додані вручну в SQL міграції.

**Було:**
```prisma
enum UserStatusEnum {
  admin
  banned
  deactivated

  @@map("user_status_enum")
}

model User {
  userId               String          @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String          @unique @db.VarChar(30)
  fullName             String          @map("full_name") @db.VarChar(100)
  email                String          @unique
  googleId             String?         @unique @map("google_id")
  bio                  String          @default("")
  passwordHash         String?         @map("password_hash")
  avatarUrl            String?         @map("avatar_url")
  socialNetworks       String[]        @default([]) @map("social_networks")
  maxStreak            Int             @default(0) @map("max_streak")
  timezone             String          @default("UTC")
  lastWatchDate        DateTime?       @map("last_watch_date") @db.Date
  profileFrameUrl      String?         @map("profile_frame_url")
  profileBackgroundUrl String?         @map("profile_background_url")
  userStatus           UserStatusEnum? @map("user_status")
  cratedAt             DateTime        @default(now()) @map("crated_at") @db.Timestamp(6)
  updatedAt            DateTime        @default(now()) @map("updated_at") @db.Timestamp(6)

  @@index([userStatus], map: "idx_user_status")
  @@index([nickname], map: "idx_nickname")
  @@map("users")
}
```

**Стало:**
```prisma
enum UserStatusEnum {
  active
  banned
  deactivated

  @@map("user_status_enum")
}

enum UserRoleEnum {
  user
  admin

  @@map("user_role_enum")
}

model User {
  userId               String         @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String         @unique @db.VarChar(30)
  fullName             String         @map("full_name") @db.VarChar(100)
  email                String         @unique
  googleId             String?        @unique @map("google_id")
  bio                  String         @default("")
  passwordHash         String?        @map("password_hash")
  avatarUrl            String?        @map("avatar_url")
  socialNetworks       String[]       @default([]) @map("social_networks")
  maxStreak            Int            @default(0) @map("max_streak")
  timezone             String         @default("UTC")
  streakStartDate      DateTime?      @map("streak_start_date") @db.Date
  lastWatchDate        DateTime?      @map("last_watch_date") @db.Date
  profileFrameUrl      String?        @map("profile_frame_url")
  profileBackgroundUrl String?        @map("profile_background_url")
  userRole             UserRoleEnum   @default(user) @map("user_role")
  userStatus           UserStatusEnum @default(active) @map("user_status")
  createdAt            DateTime       @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt            DateTime       @default(now()) @map("updated_at") @db.Timestamptz(6)

  comments       Comment[]
  animeListUnits AnimeListUnit[]
  sessions       Session[]

  @@index([userStatus], map: "idx_user_status")
  @@map("users")
}
```

## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/c0c5bde1-eb4b-41dd-a56b-aa08b25a9e33/noroot.png)


# 20261104084741_comments_remove_grade_add_is_edited

Змінено таблицю `comments`. Видалено колонку `grade`, додано колонку `is_edited` (BOOLEAN, default false). Тип `created_at` змінено на `TIMESTAMPTZ(6)`. Індекс `idx_comments_anime_id` замінено на складений індекс `idx_comments_anime_created` по `(anime_id, comment_id DESC)`. Додано `CHECK`-обмеження `comments_content_check`, яке забороняє порожній текст коментаря (воно додане вручну в SQL, бо Prisma його не підтримує).

**Було:**
```prisma
model Comment {
  commentId BigInt   @id @default(autoincrement()) @map("comment_id")
  authorId  String   @map("author_id") @db.Uuid
  animeId   String   @map("anime_id") @db.Uuid
  grade     Int?     @db.SmallInt
  content   String
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamp(6)

  author User  @relation(fields: [authorId], references: [userId], onDelete: Cascade)
  anime  Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_comments_anime_id")
  @@map("comments")
}
```

**Стало:**
```prisma
model Comment {
  commentId BigInt   @id @default(autoincrement()) @map("comment_id")
  authorId  String   @map("author_id") @db.Uuid
  animeId   String   @map("anime_id") @db.Uuid
  content   String
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamptz(6)
  isEdited  Boolean  @default(false) @map("is_edited")

  author User  @relation(fields: [authorId], references: [userId], onDelete: Cascade)
  anime  Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId, commentId(sort: Desc)], map: "idx_comments_anime_created")
  @@map("comments")
}
```

## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/edeb4a40-ccbe-462f-8907-d0458199e198/noroot.png)


# 20261104091340_init_user_links

Створено таблицю `user_links` (модель `UserLink`) з полями user_link_id (BIGSERIAL), user_id, user_link_url. Додано унікальний індекс на пару `(user_id, user_link_url)`, щоб один користувач не мав дублікатів посилань, та зовнішній ключ на `users(user_id)` з `ON DELETE CASCADE`. У моделі `User` додано зворотний зв'язок `userLinks`.

**Було:**
```prisma
// таблиця user_links відсутня
```

**Стало:**
```prisma
model UserLink {
  userLinkId  BigInt @id @default(autoincrement()) @map("user_link_id")
  userId      String @map("user_id") @db.Uuid
  userLinkUrl String @map("user_link_url")

  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@unique([userId, userLinkUrl])
  @@map("user_links")
}

// додано у моделі User
model User {
  // ...
  userLinks UserLink[]
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/c6f2f4d0-fa64-4402-b448-bb28577bba67/noroot.png)


# 20261104102452_users_migrate_social_networks_to_links

Змінено таблицю `users` та виконано міграцію даних. Значення `social_networks` перенесено в таблицю `user_links` (по одному рядку на посилання, дублікати ігноруються), після чого колонку `social_networks` видалено. Колонку `avatar_url` зроблено `NOT NULL` з default `''` (наявні `NULL` перед цим замінено на `''`). Default для `timezone` змінено на `Europe/Kyiv`. Індекс `idx_user_status` перейменовано на `idx_users_status`. Звичайні унікальні обмеження `users_nickname_key` та `users_email_key` замінено функціональними унікальними індексами `idx_users_unique_lower_nickname` та `idx_users_unique_lower_email` по `lower(...)`, щоб нікнейми й пошти були унікальними без урахування регістру. Prisma не вміє описувати такі індекси, тому `@unique` у схемі прибрано, а індекси додано вручну в SQL.

**Було:**
```prisma
enum UserStatusEnum {
  active
  banned
  deactivated

  @@map("user_status_enum")
}

enum UserRoleEnum {
  user
  admin

  @@map("user_role_enum")
}

model User {
  userId               String         @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String         @unique @db.VarChar(30)
  fullName             String         @map("full_name") @db.VarChar(100)
  email                String         @unique
  googleId             String?        @unique @map("google_id")
  bio                  String         @default("")
  passwordHash         String?        @map("password_hash")
  avatarUrl            String?        @map("avatar_url")
  socialNetworks       String[]       @default([]) @map("social_networks")
  maxStreak            Int            @default(0) @map("max_streak")
  timezone             String         @default("UTC")
  streakStartDate      DateTime?      @map("streak_start_date") @db.Date
  lastWatchDate        DateTime?      @map("last_watch_date") @db.Date
  profileFrameUrl      String?        @map("profile_frame_url")
  profileBackgroundUrl String?        @map("profile_background_url")
  userRole             UserRoleEnum   @default(user) @map("user_role")
  userStatus           UserStatusEnum @default(active) @map("user_status")
  createdAt            DateTime       @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt            DateTime       @default(now()) @map("updated_at") @db.Timestamptz(6)

  comments       Comment[]
  animeListUnits AnimeListUnit[]
  sessions       Session[]

  @@index([userStatus], map: "idx_user_status")
  @@map("users")
}
```

**Стало:**
```prisma
enum UserStatusEnum {
  active
  banned
  deactivated

  @@map("user_status_enum")
}

enum UserRoleEnum {
  user
  admin

  @@map("user_role_enum")
}

model User {
  userId               String         @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String         @db.VarChar(30)
  fullName             String         @map("full_name") @db.VarChar(100)
  email                String
  googleId             String?        @unique @map("google_id")
  bio                  String         @default("")
  passwordHash         String?        @map("password_hash")
  avatarUrl            String         @default("") @map("avatar_url")
  maxStreak            Int            @default(0) @map("max_streak")
  timezone             String         @default("Europe/Kyiv")
  streakStartDate      DateTime?      @map("streak_start_date") @db.Date
  lastWatchDate        DateTime?      @map("last_watch_date") @db.Date
  profileFrameUrl      String?        @map("profile_frame_url")
  profileBackgroundUrl String?        @map("profile_background_url")
  userRole             UserRoleEnum   @default(user) @map("user_role")
  userStatus           UserStatusEnum @default(active) @map("user_status")
  createdAt            DateTime       @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt            DateTime       @default(now()) @map("updated_at") @db.Timestamptz(6)

  comments       Comment[]
  animeListUnits AnimeListUnit[]
  sessions       Session[]
  userLinks      UserLink[]

  @@index([userStatus], map: "idx_users_status")
  @@map("users")
}
```

## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/f2ad3172-5e7a-4939-8d73-355ae22137dd/noroot.png)


# 20261104110000-rename-index-upcoming-episodes

Перейменовано індекс `idx_upcoming_episodes_date` → `idx_upcoming_episode_date` у таблиці `upcoming_episodes` для узгодженості зі звітом нормалізації (лаб. 5).

**Було:**
```prisma
@@index([episodeDate], map: "idx_upcoming_episodes_date")
```

**Стало:**
```prisma
@@index([episodeDate], map: "idx_upcoming_episode_date")
```

## Prisma Studio

![alt text](image-5.png)


# 20261104110100-remove-is-primary-from-genres

Видалено поле `is_primary` з таблиці `genres` (модель `Genre`), оскільки воно відсутнє в схемі лаб. 5.

**Було:**
```prisma
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

**Стало:**
```prisma
model Genre {
  animeId   String     @map("anime_id") @db.Uuid
  genreType GenreType  @map("genre_type")

  anime     Anime      @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, genreType])
  @@index([genreType], map: "idx_genres_genre_type")
  @@map("genres")
}
```

## Prisma Studio
![alt text](image-7.png)


# 20261104110300-sync-animes-with-lab5

Синхронізовано таблицю `animes` зі схемою лаб. 5 (повна синхронізація).

**Зміни:**
- Додано колонку `anime_description TEXT NOT NULL DEFAULT ''`
- `cover_url` та `production_studio` → `NOT NULL DEFAULT ''`
- Типи: `mal_id`, `anilist_id` → `BIGINT`; `year_released`, `avg_episode_duration`, `episodes_count` → `SMALLINT`
- Унікальність: `mal_id`, `anilist_id`, `hikka_id`, `imdb_id`
- CHECK constraints: `year_released >= 1900`, `avg_episode_duration >= 0`, `episodes_count >= 0`
- Enum `anime_status_enum`: `dropped` → `cancelled`

**Було:**
```prisma
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
}
```

**Стало:**
```prisma
model Anime {
  animeId            String       @id @default(uuid()) @map("anime_id")
  slug               String       @unique
  titleUa            String       @default("") @map("title_ua")
  titleEn            String       @default("") @map("title_en")
  titleOriginal      String       @default("") @map("title_original")
  description        String       @default("") @map("anime_description")
  coverUrl           String       @default("") @map("cover_url")
  productionStudio   String       @default("") @map("production_studio")
  malId              BigInt?      @unique @map("mal_id")
  anilistId          BigInt?      @unique @map("anilist_id")
  hikkaId            String?      @unique @map("hikka_id")
  imdbId             String?      @unique @map("imdb_id")
  yearReleased       Int?         @db.SmallInt @map("year_released")
  avgEpisodeDuration Int          @default(0) @db.SmallInt @map("avg_episode_duration")
  episodeCount       Int          @default(0) @db.SmallInt @map("episode_count")
  ageRestriction     MpaaRating?  @map("age_restriction")
  animeStatus        AnimeStatus? @map("anime_status")
  animeFormat        AnimeFormat  @default(tv) @map("anime_format")
  available          Boolean      @default(true) @map("available")
}
```

## Prisma Studio
![alt text](image-8.png)


# 20261104121000-sync-genres-enum-with-lab5

Синхронізовано enum `genre_type_enum` з лаб. 5 (додано нові значення жанрів) та перейменовано індекс `idx_genres_genre_type` → `idx_genres_type`.

**Було:**
```prisma
@@index([genreType], map: "idx_genres_genre_type")
```

**Стало:**
```prisma
@@index([genreType], map: "idx_genres_type")
```

## Prisma Studio

![alt text](image-9.png)


# 20261104121500-sync-upcoming-episodes-with-lab5

Синхронізовано таблицю `upcoming_episodes` зі схемою лаб. 5.

**Зміни:**
- Додано сурогатний ключ `upcoming_episode_id UUID PRIMARY KEY DEFAULT uuidv7()`
- Видалено складений PK `(anime_id, episode_name)` → додано `UNIQUE(anime_id, episode_name)`
- Додано CHECK constraint: `length(trim(episode_name)) > 0`

**Було:**
```prisma
model UpcomingEpisode {
  animeId     String   @map("anime_id") @db.Uuid
  episodeName String   @map("episode_name")
  episodeDate DateTime @default(now()) @map("episode_date")

  anime      Anime    @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, episodeName])
  @@index([episodeDate], map: "idx_upcoming_episode_date")
  @@map("upcoming_episodes")
}
```

**Стало:**
```prisma
model UpcomingEpisode {
  upcomingEpisodeId UUID     @id @default(uuid()) @map("upcoming_episode_id") @db.Uuid
  animeId           String   @map("anime_id") @db.Uuid
  episodeName       String   @map("episode_name")
  episodeDate       DateTime @default(now()) @map("episode_date")

  anime             Anime    @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@unique([animeId, episodeName])
  @@index([episodeDate], map: "idx_upcoming_episode_date")
  @@map("upcoming_episodes")
}
```

## Prisma Studio

![alt text](image-10.png)

