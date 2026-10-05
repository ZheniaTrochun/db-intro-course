# sessions by @ApostolQleg

## ❇️ Create table
Мета, очікуваний результат, чи успішно виконано

```SQL
CREATE TABLE sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token BYTEA NOT NULL UNIQUE CHECK(length(refresh_token) = 96),
    expire_time TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '1 year',
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
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
