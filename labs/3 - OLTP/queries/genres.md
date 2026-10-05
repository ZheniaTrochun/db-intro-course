# genres by @XxMariavxX

## ❇️ Create table
Мета, очікуваний результат, чи успішно виконано

```SQL
CREATE TYPE genre_type_enum AS ENUM(
    'action', 'adventure',
    'avant_garde', 'boys_love',
    'comedy', 'demons',
    'drama', 'ecchi',
    'fantasy', 'girls_love',
    'gourmet', 'harem',
    'hentai', 'historical',
    'horror', 'isekai',
    'josei', 'kids',
    'magic', 'martial_arts',
    'mecha', 'military',
    'music', 'mystery',
    'parody', 'psychological',
    'romance', 'samurai',
    'school', 'sci_fi',
    'seinen', 'shoujo',
    'shoujo_ai', 'shounen',
    'shounen_ai', 'slice_of_life',
    'space', 'sports',
    'supernatural', 'super_power',
    'suspense', 'thriller',
    'vampire'
);

CREATE TABLE genres(
  anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
  genre_type genre_type_enum NOT NULL,

  PRIMARY KEY(anime_id, genre_type)
);

CREATE INDEX idx_genre_type ON genres(genre_type);
```


## 🗑 Drop table

```SQL
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
