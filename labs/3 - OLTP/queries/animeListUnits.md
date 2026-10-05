# animeListUnits by @dadencukillia

## ❇️ Create table
Створити таблицю anime_list_units, таблиця успішно створюється у базі даних, виконання успішне.

```SQL
CREATE TYPE anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE anime_list_units(
  user_id UUID NOT NULL,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  watched_episodes INT NOT NULL DEFAULT 0 CHECK(watched_episodes >= 0),
  repeat_times INT NOT NULL DEFAULT 0 CHECK(repeat_times >= 0),
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',
  grade SMALLINT CHECK(grade BETWEEN -5 AND 5)

  PRIMARY KEY(user_id, anime_id)
);
```


## 🗑 Drop table

```SQL
DROP TABLE anime_list_units;
```


## ✨ Insert queries

### All colums
Заповнити таблицю anime_list_units детермінованими записами. Таблиця отримала 5 нових записів, запит виконано успішно.

```SQL
INSERT INTO anime_list_units(user_id, anime_id, watched_episodes, repeat_times, started_watching, list_unit_status, grade) VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 1, 0, now()::date - INTERVAL '1 day', 'watching', NULL),
    ('11111111-1111-4111-8111-111111111111', '40404040-4040-4040-4040-404040404040', 10, 2, now()::date, 'finished', NULL),
    ('67676767-6767-6767-6767-676767676767', '40404040-4040-4040-4040-404040404040', 12, 0, '2008-01-08', 'finished', 5),
    ('14881488-1488-1488-1488-148814881488', '34343434-3434-3434-3434-343434343434', 3, 0, '2020-12-12', 'dropped', -5),
    ('67676767-6767-6767-6767-676767676767', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 5, 10, '2023-01-28', 'delayed', 2);
```

### Mandatory only colums
Додати у таблицю записи про початок перегляду тайтлів юзерами. Таблиця отримала 5 нових записів, запит виконано успішно.

```SQL
INSERT INTO anime_list_units(user_id, anime_id) VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce'),
    ('11111111-1111-4111-8111-111111111111', '40404040-4040-4040-4040-404040404040'),
    ('67676767-6767-6767-6767-676767676767', '40404040-4040-4040-4040-404040404040'),
    ('14881488-1488-1488-1488-148814881488', '34343434-3434-3434-3434-343434343434'),
    ('67676767-6767-6767-6767-676767676767', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce');
```

### With returning part (`RETURNING`)
Додати аніме у список користувача повертаючи всю необхідну інформацію, щоб воно відразу могло відображатися в UI.
У таблицю додається один запис, а результатом повертається інформація про додане аніме та його статус в списку користувача.
Запит виконується успішно.

```SQL
WITH list_unit AS (
	INSERT INTO anime_list_units(user_id, anime_id) VALUES
	    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce')
	RETURNING anime_id, watched_episodes, repeat_times, list_unit_status, grade
) SELECT 
	list_unit.anime_id, list_unit.watched_episodes, list_unit.repeat_times, list_unit.list_unit_status, list_unit.grade,
	animes.slug, animes.title_ua, animes.title_en, animes.title_original, animes.cover_url
FROM list_unit
INNER JOIN animes
ON animes.anime_id = list_unit.anime_id;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
Отримати всі записи з таблички з усіма полями. Запит виконується без помилок.

```SQL
SELECT * FROM anime_list_units;
```

### Select public only info (no `WHERE`, specified fields)
Отримати всі записи з таблички з усіма публічними полями. Запит виконується без помилок.

```SQL
SELECT user_id, anime_id, watched_episodes, repeat_times, list_unit_status, grade FROM anime_list_units;
```

### API production example
Отримується всі публічні дані у записах списку користувача та даних аніме для відображення в UI.
Запити сортуються так, щоб спочатку йшли новододані, а ті тайтли що були додані у список
в один день будуть відображатися по кількості переглянутих епізодів у спадаючому порядку.
Також є пагінація (по 100 записів на сторінку), а Backend має підставляти коефіцієнт для числа 100 в
OFFSET, щоб вказати сторінку (5 - це шоста сторінка, 0 - це перша).
Запит виконується без помилок (через неймовірну малу кількість записів у БД
слід поставити першу сторінку, щоб побачити результат).

`GET /api/user/11111111-1111-4111-8111-111111111111/list`
```SQL
SELECT 
    list_unit.anime_id, list_unit.watched_episodes, list_unit.repeat_times, list_unit.list_unit_status, list_unit.grade,
	animes.slug, animes.title_ua, animes.title_en, animes.title_original, animes.cover_url
FROM anime_list_units AS list_unit
INNER JOIN animes ON
    animes.anime_id = list_unit.anime_id
WHERE
    list_unit.user_id = '11111111-1111-4111-8111-111111111111'
ORDER BY list_unit.started_watching DESC, list_unit.watched_episodes DESC
LIMIT 100
OFFSET 100 * 5;
```


## 🔄 Update queries

### Update some fields (`WHERE`)
Оновити інформацію в записі списку користувача, якщо користувач
вкаже, що він переглянув 10 серій по другому колу та вже завершив перегляд.
Виконання успішне, без помилок.

```SQL
UPDATE anime_list_units
SET watched_episodes = 10,
    repeat_times = 1,
    list_unit_status = 'finished',
    grade = 5
WHERE
    user_id = '11111111-1111-4111-8111-111111111111' AND
    anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce';
```

### Update fields returning values (`WHERE`, `RETURNING`)
Оновити запис та повернути старі дані. Запит виконується успішно

```SQL
UPDATE anime_list_units
SET watched_episodes = 10,
    repeat_times = 1,
    list_unit_status = 'finished',
    grade = 5
WHERE
    user_id = '11111111-1111-4111-8111-111111111111' AND
    anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce'
RETURNING old.watched_episodes, old.repeat_times, old.list_unit_status, old.grade;
```

### Some interesting examples

Користувач може захотіти оновити кількість переглянутих серій.
Тоді було б добре прирівняти кількість серій аніме до його лічильника.
Першим ділом його лічильник не має перебільшувати кількість серій аніме, а
другим ділом було б добре оновлювати статус на `finished` якщо він глянув всі серії аніме
на останньому колі.

```SQL
WITH entry AS (
    SELECT
        list_unit.user_id, list_unit.anime_id, list_unit.list_unit_status, 
        animes.episodes_count,
        10 AS watched_episodes -- replace on backend
    FROM anime_list_units AS list_unit
    INNER JOIN animes ON
        animes.anime_id = list_unit.anime_id
    WHERE 
        list_unit.user_id = '11111111-1111-4111-8111-111111111111' AND
        list_unit.anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce'
    LIMIT 1
) UPDATE anime_list_units AS target
SET watched_episodes = least(entry.watched_episodes, entry.episodes_count),
    list_unit_status = CASE
        WHEN entry.watched_episodes >= entry.episodes_count THEN 'finished'
        ELSE entry.list_unit_status
    END
FROM entry
WHERE
    target.user_id = entry.user_id AND
    target.anime_id = entry.anime_id
RETURNING target.watched_episodes, target.repeat_times, target.list_unit_status;
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
Видалити всі записи. Запит виконується без проблем.

```SQL
DELETE FROM anime_list_units;
```

### Delete with filter (`WHERE`)
Видалити запис про аніме з акаунту користувача. Запит виконується успішно.

```SQL
DELETE FROM anime_list_units
WHERE
    user_id = '11111111-1111-4111-8111-111111111111' AND
    anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce';
```

### Delete and return (`WHERE`, `RETURNING`)
Видалити запис про аніме з акаунту користувача та повернути видалені дані. Запит виконується успішно.

```SQL
DELETE FROM anime_list_units
WHERE
    user_id = '11111111-1111-4111-8111-111111111111' AND
    anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce'
RETURNING watched_episodes, repeat_times, list_unit_status;
```
