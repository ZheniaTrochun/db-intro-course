# Структура таблиць і їхні зв'язки

## Користувачі — `users`

- `user_id` (`UUID`)
- `nickname` (`VARCHAR`)
- `full_name` (`VARCHAR`)
- `email` (`TEXT`)
- `google_id` (`TEXT`)
- `bio` (`TEXT`)
- `password_hash` (`TEXT`)
- `avatar_url` (`TEXT`)
- `social_networks` (`TEXT[]`)
- `max_streak` (`INTEGER`)
- `timezone` (`TEXT`)
- `last_watch_date` (`DATE`)
- `profile_frame_url` (`TEXT`)
- `profile_background_url` (`TEXT`)
- `user_status` (`ENUM user_status_enum`)
- `created_at` (`TIMESTAMP`)
- `updated_at` (`TIMESTAMP`)

- **PK:** `user_id`
- **UNIQUE:** `nickname`, `email`, `google_id`
- **INDEXES:** `nickname`, `user_status`

## Каталог аніме — `animes`

- `anime_id` (`UUID`)
- `slug` (`TEXT`)
- `title_ua` (`TEXT`)
- `title_en` (`TEXT`)
- `title_original` (`TEXT`)
- `anime_description` (`TEXT`)
- `cover_url` (`TEXT`)
- `production_studio` (`TEXT`)
- `mal_id` (`INT`)
- `anilist_id` (`INT`)
- `hikka_id` (`INT`)
- `imdb_id` (`INT`)
- `year_released` (`SMALLINT`)
- `avg_episode_duration` (`SMALLINT`)
- `age_restriction` (`ENUM mpaa_rating_enum`)
- `anime_status` (`ENUM anime_status_enum`)
- `anime_format` (`ENUM anime_format_enum`)
- `available` (`BOOLEAN`)

- **PK:** `anime_id`
- **UNIQUE:** `slug`
- **CHECK:** `year_released >= 1900`
- **INDEXES:** `slug`, `available`

## Жанри аніме — `genres`

- `anime_id` (`UUID`)
- `genre_type` (`ENUM genre_type`)

- **PK:** (`anime_id`, `genre_type`)
- **FK:** `anime_id` → `animes(anime_id)` `ON DELETE CASCADE`

## Випущені епізоди — `episodes`

- `episode_id` (`BIGSERIAL`)
- `anime_id` (`UUID`)
- `source_url` (`TEXT`)
- `episode_name` (`TEXT`)
- `localization_studio` (`TEXT`)
- `localization_type` (`ENUM episode_localization_type_enum`)

- **PK:** `episode_id`
- **FK:** `anime_id` → `animes(anime_id)` `ON DELETE CASCADE`
- **INDEXES:** `anime_id`

## Анонси майбутніх аніме — `upcoming_episodes`

- `anime_id` (`UUID`)
- `episode_name` (`TEXT`)
- `episode_date` (`TIMESTAMP`)

- **PK:** (`anime_id`, `episode_date`)
- **FK:** `anime_id` → `animes(anime_id)` `ON DELETE CASCADE`

## Списки перегляду — `anime_list_units`

- `user_id` (`UUID`)
- `anime_id` (`UUID`)
- `watched_episodes` (`INTEGER`)
- `repeat_times` (`INTEGER`)
- `started_watching` (`DATE`)
- `list_unit_status` (`ENUM anime_list_unit_status_enum`)

- **PK:** (`user_id`, `anime_id`)
- **FK:** `user_id` → `users(user_id)`
- **FK:** `anime_id` → `animes(anime_id)` `ON DELETE CASCADE`

## Коментарі та оцінки — `comments`

- `comment_id` (`BIGSERIAL`)
- `author_id` (`UUID`)
- `anime_id` (`UUID`)
- `grade` (`SMALLINT`)
- `content` (`TEXT`)
- `created_at` (`TIMESTAMP`)

- **PK:** `comment_id`
- **FK:** `author_id` → `users(user_id)` `ON DELETE CASCADE`
- **FK:** `anime_id` → `animes(anime_id)` `ON DELETE CASCADE`
- **CHECK:** `grade BETWEEN -5 AND 5`
- **INDEXES:** `anime_id`

## Сесії авторизації — `sessions`

- `session_id` (`BIGSERIAL`)
- `user_id` (`UUID`)
- `refresh_token` (`CHAR(128)`)
- `device_type` (`TEXT`)
- `device_name` (`TEXT`)
- `os` (`TEXT`)
- `browser` (`TEXT`)
- `user_agent` (`TEXT`)
- `user_location` (`TEXT`)
- `ip_address` (`INET`)

- **PK:** `session_id`
- **FK:** `user_id` → `users(user_id)` `ON DELETE CASCADE`
- **UNIQUE:** `refresh_token`
- **INDEXES:** `refresh_token`