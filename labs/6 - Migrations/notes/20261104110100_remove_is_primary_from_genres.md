# 20261104110100-remove-is-primary-from-genres

Видалено поле `is_primary` з таблиці `genres` (модель `Genre`), оскільки воно відсутнє в схемі лаб. 5.

**Було:**
```prisma
model Genre {
  animeId   String     @map("anime_id") @db.Uuid
  genreType GenreType  @map("genre_type")
  isPrimary Boolean    @default(false) @map("is_primary")

  anime     Anime      @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, genreType])
  @@index([genreType], map: "idx_genres_genre_type")
  @@map("genres")
}
```

**Стало:**
```prisma
model Genre {
  animeId   String     @map("anime_id") @db.Uuid
  genreType GenreType  @map("genre_type")

  anime     Anime      @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, genreType])
  @@index([genreType], map: "idx_genres_genre_type")
  @@map("genres")
}
```

## Prisma Studio
[alt text](image-7.png)
