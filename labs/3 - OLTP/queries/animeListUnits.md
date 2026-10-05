# animeListUnits by @dadencukillia

## ❇️ Create table
Створити таблицю anime_list_units, таблиця успішно створюється у базі даних, виконання успішне

```SQL
CREATE TYPE anime_list_unit_status_enum AS ENUM('finished', 'watching', 'delayed', 'dropped');

CREATE TABLE anime_list_units(
  user_id UUID NOT NULL,
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  watched_episodes INT NOT NULL DEFAULT 0 CHECK(watched_episodes >= 0),
  repeat_times INT NOT NULL DEFAULT 0 CHECK(repeat_times >= 0),
  started_watching DATE NOT NULL DEFAULT now()::date,
  list_unit_status anime_list_unit_status_enum NOT NULL DEFAULT 'watching',

  PRIMARY KEY(user_id, anime_id)
);
```


## 🗑 Drop table

```SQL
DROP TABLE anime_list_units;
```


## ✨ Insert queries

### All colums
Заповнити таблицю anime_list_units детермінованими записами. Таблиця отримала 5 нових записів, запит виконано успішно

```SQL
INSERT INTO anime_list_units(user_id, anime_id, watched_episodes, repeat_times, started_watching, list_unit_status) VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 1, 0, now()::date - INTERVAL '1 day', 'watching'),
    ('11111111-1111-4111-8111-111111111111', '40404040-4040-4040-4040-404040404040', 10, 2, now()::date, 'finished'),
    ('67676767-6767-6767-6767-676767676767', '40404040-4040-4040-4040-404040404040', 12, 0, '2008-01-08', 'finished'),
    ('14881488-1488-1488-1488-148814881488', '34343434-3434-3434-3434-343434343434', 3, 0, '2020-12-12', 'dropped'),
    ('67676767-6767-6767-6767-676767676767', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 5, 10, '2023-01-28', 'delayed');
```

### Mandatory only colums
Додати у таблицю записи про початок перегляду тайтлу юзером. Таблиця отримала 5 нових записів, запит виконано успішно

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
	INSERT INTO anime_list_units(user_id, anime_id, watched_episodes, repeat_times, started_watching, list_unit_status) VALUES
	    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce')
	RETURNING anime_id, watched_episodes, repeat_times, list_unit_status
) SELECT 
	list_unit.anime_id, list_unit.watched_episodes, list_unit.repeat_times, list_unit.list_unit_status,
	animes.slug, animes.title_ua, animes.title_en, animes.title_original, animes.cover_url 
FROM list_unit
INNER JOIN animes
ON animes.anime_id = list_unit.anime_id;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
Отримати всі записи з таблички з усіма полями. Запит виконується без помилок

```SQL
SELECT * FROM anime_list_units;
```

### Select public only info (no `WHERE`, specified fields)
Отримати всі записи з таблички з усіма публічними полями. Запит виконується без помилок

```SQL
SELECT user_id, anime_id, watched_episodes, repeat_times, list_unit_status FROM anime_list_units;
```

### API production example
Отримується всі публічні дані у записах списку користувача для відображення в UI.
Запити сортуються так, щоб спочатку йшли новододані, а ті тайтли що були додані у список
в один день будуть відображатися по кількості переглянутих епізодів у спадаючому порядку.
Запит виконується без помилок.

`GET /api/user/11111111-1111-4111-8111-111111111111/list`
```SQL
SELECT anime_id, watched_episodes, repeat_times, list_unit_status
FROM anime_list_units
WHERE user_id = '11111111-1111-4111-8111-111111111111'
ORDER BY started_watching DESC, watched_episodes DESC;
```

### Some interesting examples (optional)

- [ ] ORDER BY
- [ ] LIMIT
- [ ] OFFSET
- [ ] JOIN
- [ ] GROUP BY

Мета, очікуваний результат, чи успішно виконано

```SQL
```

Мета, очікуваний результат, чи успішно виконано

```SQL
```


## 🔄 Update queries

### Update some fields (`WHERE`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Update fields returning values (`WHERE`, `RETURNING`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Some interesting examples (optional)

Мета, очікуваний результат, чи успішно виконано

```SQL
```

Мета, очікуваний результат, чи успішно виконано

```SQL
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Delete with filter (`WHERE`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Delete and return (`WHERE`, `RETURNING`)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Some interesting examples (optional)

Мета, очікуваний результат, чи успішно виконано

```SQL
```

Мета, очікуваний результат, чи успішно виконано

```SQL
```
