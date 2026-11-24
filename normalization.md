# Нормалізація

## 1. Поточні таблиці в базі даних

`users`
```sql
CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE CHECK (user_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    user_password_hash VARCHAR(100) NOT NULL,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
`artists`
```sql
CREATE TABLE artists (
    artist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_user_id BIGINT NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    artist_name VARCHAR(100) NOT NULL CHECK (btrim(artist_name) <> ''),
    artist_bio VARCHAR(500)
);
```
`albums`
```sql
CREATE TABLE albums (
    album_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    album_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    album_name VARCHAR(100) NOT NULL CHECK (btrim(album_name) <> ''),
    released_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
`tracks`
```sql
CREATE TABLE tracks (
    track_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    track_album_id BIGINT REFERENCES albums(album_id) ON DELETE SET NULL,
    track_name VARCHAR(100) NOT NULL CHECK (btrim(track_name) <> ''),
    track_duration_milliseconds INTEGER NOT NULL CHECK (track_duration_milliseconds >= 1 AND track_duration_milliseconds <= 900000),
    track_audio_url VARCHAR(100) NOT NULL UNIQUE,
    released_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
`playlists`
```sql
CREATE TABLE playlists (
    playlist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    playlist_user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    playlist_name VARCHAR(100) NOT NULL CHECK (btrim(playlist_name) <> '') DEFAULT 'New Playlist',
    playlist_view PLAYLIST_VIEW_ENUM NOT NULL DEFAULT 'private',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```
`artist_monthly_stats`
```sql
CREATE TABLE artist_monthly_stats (
    stats_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    stats_month DATE NOT NULL CHECK (EXTRACT(DAY FROM stats_month) = 1),
    stats_play_count INTEGER NOT NULL CHECK (stats_play_count >= 0),
    PRIMARY KEY (stats_artist_id, stats_month)
);
```
`track_features`
```sql
CREATE TABLE track_features (
    artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    track_id BIGINT NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
    PRIMARY KEY (artist_id, track_id)
);
```
`playlist_tracks`
```sql
CREATE TABLE playlist_tracks (
    playlist_id BIGINT NOT NULL REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    track_id BIGINT NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
    track_position INTEGER NOT NULL CHECK (track_position >= 1),
    added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, track_id),
    
    CONSTRAINT unique_track_position UNIQUE(playlist_id, track_position) DEFERRABLE INITIALLY DEFERRED
);
```
## 2. Перевірка 1NF
### 2.1. Вимоги 1NF
- Кожен атрибут має атомарне значення
- Немає повторюваних груп атрибутів
- Кожна таблиця має первинний ключ

### 2.2. Перевірка
- Кожен атрибут кожної таблиці дійсно є атомарним.
- У кожній таблиці немає повторюваних груп атрибутів.
- Кожна таблиця має первинний ключ (складенний для таблиць `artist_monthly_stats`, `track_features`, `playlist_tracks`).

### 2.3 Висновок
База даних вже перебуває у 1NF.

## 3. Перевірка 2NF
### 3.1. Вимоги 2NF
- База даних вже перебуває у 1NF.
- Кожен неключовий атрибут залежить від усього кандидатного ключа (не від його частини).

### 3.2. Перевірка
- База даних вже перебуває у 1NF.
- В таблицях без складенного первинного ключа, усі атрибути залежать від усього первинного ключа (`BIGINT` ідентифікатор).
- Подивимось на таблиці, які мають складенний первинний ключ:
  - `artist_monthly_stats` має `PRIMARY KEY (stats_artist_id, stats_month)`. Єдиний неключовий атрибут `stats_play_count` залежить і від певного виконавця, і від певного місяця.
  - `track_features` має `PRIMARY KEY (artist_id, track_id)`. Таблиця є асоціативною сутністю та не несе додаткових неключових атрибутів.
  - `playlist_tracks` має `PRIMARY KEY (playlist_id, track_id)`. Таблиця є асоціативною сутністю та має два неключових атрибути: `track_position` та `added_at`. Позиція треку та час його додавання повністю залежить від певного плейліста та певного треку.

### 3.3. Висновок
База даних вже перебуває у 2NF.

## 4. Перевірка 3NF
### 4.1. Вимоги 3NF
- База даних вже перебуває у 2NF.
- Немає бути транзитивних залежностей. Інакше кажучи: немає жодного неключового атрибута, який залежить від іншого неключового атрибута.

### 4.2. Перевірка 3NF
- База даних вже перебуває у 2NF.
- В цілому, всі залежності між таблицями не є транзитивними, окрім зв'язку `tracks` - `albums`.

### 4.3. Детальний огляд зв'язку `tracks` - `albums`
Таблиця `tracks`:
```sql
CREATE TABLE tracks (
    track_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    track_album_id BIGINT REFERENCES albums(album_id) ON DELETE SET NULL,
    ...
);
```
За бізнес логікою, в альбомі певного виконавця має бути тільки треки, у яких головний виконавець я автором цього альбому. Також трек може не належати жодному альбому (single).
З цього випливає, що `track_album_id` може бути `NULL`, а якщо не `NULL` то `album_artist_id` з таблиці `albums` має співпадати з `track_artist_id`.<br>
Виходить така ситуація, що якщо `track_album_id` не `NULL` то `track_artist_id` залежить від `album_artist_id`, але `album_artist_id` - це неключовий атрибут.
Це може призвести до аномалій вставки та видалення і, відповідно, є порушенням 3NF.

### 4.4. Потенційні рішення проблеми
- Перше, що можна було б зробити, це видалити `track_artist_id` з таблиці `tracks`, але тоді, якщо трек є синглом, втрачається інформація про виконавця. Не підходить.
- Потенційним рішенням може бути створення асоціативної таблиці `track_artists`:
```sql
CREATE TYPE ARTIST_ROLE AS ENUM (
    'Main',
    'Feature'
);
CREATE TABLE track_artists (
    track_artist_id BIGINT NOT NULL REFERENCES artists(artist_id) ON DELETE CASCADE,
    track_id BIGINT NOT NULL REFERENCES tracks(track_id) ON DELETE CASCADE,
    artist_role ARTIST_ROLE NOT NULL,
    PRIMARY KEY(track_artist_id, track_id, artist_role)
);
```
