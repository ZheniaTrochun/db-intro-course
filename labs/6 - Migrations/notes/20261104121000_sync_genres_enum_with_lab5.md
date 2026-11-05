# 20261104121000-sync-genres-enum-with-lab5

Синхронізовано enum `genre_type_enum` з лаб. 5 (додано нові значення жанрів) та перейменовано індекс `idx_genres_genre_type` → `idx_genres_type`.

**Було:**
```prisma
@@index([genreType], map: "idx_genres_genre_type")
```

**Стало:**
```prisma
@@index([genreType], map: "idx_genres_type")
```

## Prisma Studio

![alt text](https://ucarecdn.com/e0e2ca89-9664-4f6e-b6fd-f0c3872a3a1c/image9.png)
