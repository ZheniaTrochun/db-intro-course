# episodes by @dadencukillia

## ❇️ Create table
Створити таблицю episodes, таблиця успішно створюється у базі даних, виконання успішне.

```SQL
CREATE TYPE episode_localization_type_enum AS ENUM('sub', 'dub');

CREATE TABLE episodes(
  episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  source_url TEXT NOT NULL,
  episode_name TEXT NOT NULL CHECK(length(trim(episode_name)) > 0),
  localization_studio TEXT NOT NULL DEFAULT '',
  localization_type episode_localization_type_enum
);

CREATE INDEX idx_episodes_anime_id ON episodes(anime_id);
```


## 🗑 Drop table

```SQL
DROP TABLE episodes;
```


## ✨ Insert queries

### All colums
Наповнити таблицю episodes записами. Таблиця отримала 7 нових записів, запит виконано успішно.

```SQL
INSERT INTO episodes(anime_id, source_url, episode_name, localization_studio, localization_type) VALUES
    ('34343434-3434-3434-3434-343434343434', 'https://minecraft.net/trailer.mp4', 'EP1', 'ДжекРіден', 'sub'),
    ('40404040-4040-4040-4040-404040404040', 'https://archlinux.org/how-to-install-linux.mp4', 'SP1', 'Clan Kaizoku', 'dub'),
    ('34343434-3434-3434-3434-343434343434', 'https://cdn.microsoft.net/how-to-uninstall-windows.mp4', 'EP2', 'ДжекРіден', 'sub'),
    ('40404040-4040-4040-4040-404040404040', 'https://cdn.youtube.com/w/aoAOkfOji.mp4', 'MOVIE', 'Clan Kaizoku', 'dub'),
    ('f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'https://esp32.com/tutorial.mp4', 'EP1', 'FanVoxUA', 'dub'),
    ('f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'https://twitch.tv/stream/JjfiiUFAInj.m3u8', 'EP1.5', 'FanVoxUA', 'dub'),
    ('f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'https://darknet.com/dark-videos.mp4', 'EP2', 'FanVoxUA', 'dub');
```

### With returning part (`RETURNING`, optional)
Наповнити таблицю episodes записами та повернути їхні дані. Таблиця отримала 7 нових записів, запит виконано успішно.

```SQL
INSERT INTO episodes(anime_id, source_url, episode_name, localization_studio, localization_type) VALUES
    ('34343434-3434-3434-3434-343434343434', 'https://minecraft.net/trailer.mp4', 'EP1', 'ДжекРіден', 'sub'),
    ('40404040-4040-4040-4040-404040404040', 'https://archlinux.org/how-to-install-linux.mp4', 'SP1', 'Clan Kaizoku', 'dub'),
    ('34343434-3434-3434-3434-343434343434', 'https://cdn.microsoft.net/how-to-uninstall-windows.mp4', 'EP2', 'ДжекРіден', 'sub'),
    ('40404040-4040-4040-4040-404040404040', 'https://cdn.youtube.com/w/aoAOkfOji.mp4', 'MOVIE', 'Clan Kaizoku', 'dub'),
    ('f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'https://esp32.com/tutorial.mp4', 'EP1', 'FanVoxUA', 'dub'),
    ('f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'https://twitch.tv/stream/JjfiiUFAInj.m3u8', 'EP1.5', 'FanVoxUA', 'dub'),
    ('f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'https://darknet.com/dark-videos.mp4', 'EP2', 'FanVoxUA', 'dub')
RETURNING anime_id, source_url, episode_name, localization_studio, localization_type;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
Отримати всі записи серій. Таблиця повертає успішно всі 7 запитів.

```SQL
SELECT * FROM episodes;
```

### Select public only info (no `WHERE`, specified fields)
Отримати публічні дані записів серій. Запит успішно повертає всі поля.

```SQL
SELECT anime_id, source_url, episode_name, localization_studio, localization_type
FROM episodes;
```

### API production example
Отримати всі серії конкретного аніме. Запит успішно повертає 3 записи.

`GET /api/anime/f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce/episodes`
```SQL
SELECT source_url, episode_name, localization_studio, localization_type
FROM episodes
WHERE anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce';
```


## 🔄 Update queries

### Update some fields (`WHERE`)
Якщо якийсь провайдер переїде на інший домен, можна скористатися таким запитом для заміни.
Запит успішно заміняє домен у конкретному випадку в одному записі.

```SQL
UPDATE episodes
SET source_url = replace(source_url, 'https://darknet.com', 'https://darknet.net')
WHERE source_url LIKE 'https://darknet.com%';
```

### Update fields returning values (`WHERE`, `RETURNING`)
Виконати заміну домену та повернути змінені записи. Запит виконується успішно.

```SQL
UPDATE episodes
SET source_url = replace(source_url, 'https://darknet.com', 'https://darknet.net')
WHERE source_url LIKE 'https://darknet.com%'
RETURNING anime_id, source_url, episode_name, localization_studio, localization_type;
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
Видалити всі записи з таблички episodes. Запит виконується без проблем.

```SQL
DELETE FROM episodes;
```

### Delete with filter (`WHERE`)
Видалити всі записи серій якщо якась студія проти публікації їхніх робіт.
Запит успішно видаляє потрібні записи.

```SQL
DELETE FROM episodes
WHERE localization_studio = 'FanVoxUA';
```

### Delete and return (`WHERE`, `RETURNING`)
Видалити та повернути всі записи серій якщо якась студія проти публікації їхніх робіт.
Запит успішно видаляє потрібні записи.

```SQL
DELETE FROM episodes
WHERE localization_studio = 'FanVoxUA'
RETURNING anime_id, source_url, episode_name, localization_studio, localization_type;
```
