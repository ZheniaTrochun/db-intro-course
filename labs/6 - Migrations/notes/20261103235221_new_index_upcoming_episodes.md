# 20261103235221_new_index_upcoming_episodes

Додано мапінги `@map`/`@@map` для моделі `UpcomingEpisode`. Додано індекс `idx_upcoming_episodes_date` на колонку `episode_date`. Змінено зовнішній ключ `upcoming_episodes_anime_id_fkey` на `ON DELETE CASCADE`.

**Було:**
```prisma
model UpcomingEpisode {
  animeId     String
  episodeName String
  episodeDate DateTime @default(now())

  anime      Anime    @relation(fields: [animeId], references: [animeId])

  @@id([animeId, episodeName])
  // @@map та @map відсутні
}
```

**Стало:**
```prisma
model UpcomingEpisode {
  animeId     String   @map("anime_id") @db.Uuid
  episodeName String   @map("episode_name")
  episodeDate DateTime @default(now()) @map("episode_date")

  anime      Anime    @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, episodeName])
  @@index([episodeDate], map: "idx_upcoming_episodes_date")
  @@map("upcoming_episodes")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://example.com)
