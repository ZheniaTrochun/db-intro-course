# users by @ApostolQleg

## ❇️ Create table
Мета, очікуваний результат, чи успішно виконано

```SQL
CREATE TYPE user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE user_role_enum AS ENUM('user', 'admin');

CREATE TABLE users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT,
    social_networks TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'UTC',
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX idx_user_status ON users(user_status);
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
