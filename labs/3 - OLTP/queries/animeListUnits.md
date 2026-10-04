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
DROP TABLE anime_list_units CASCADE;
```


## ✨ Insert queries

### All colums
Мета, очікуваний результат, чи успішно виконано

```SQL
INSERT INTO anime_list_units(user_id, anime_id, watched_episodes, repeat_times, started_watching, list_unit_status) VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 1, 0, now()::date - INTERVAL 'day', 'watching'),
    ('11111111-1111-4111-8111-111111111111', '40404040-4040-4040-4040-404040404040', 10, 2, now()::date, 'finished'),
    ('67676767-6767-6767-6767-676767676767', '40404040-4040-4040-4040-404040404040', 12, 0, '2008-01-08', 'finished'),
    ('14881488-1488-1488-1488-148814881488', '34343434-3434-3434-3434-343434343434', 3, 0, '2020-12-12', 'dropped'),
    ('67676767-6767-6767-6767-676767676767', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 5, 10, '2023-01-28', 'delayed');
```

### Mandatory only colums
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### With returning part (`RETURNING`, optional)
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


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### Select public only info (no `WHERE`, specified fields)
Мета, очікуваний результат, чи успішно виконано

```SQL
```

### API production example (like in `GET /api/anime/:id/comments`, `GET /api/user` etc)
Мета, очікуваний результат, чи успішно виконано

`GET /api/anime/:id/comments` (replace it with your endpoint example, erase these brackets)
```SQL
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
