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

### IDs

- ``
- ``
- ``

### All colums
Мета, очікуваний результат, чи успішно виконано

```SQL
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
