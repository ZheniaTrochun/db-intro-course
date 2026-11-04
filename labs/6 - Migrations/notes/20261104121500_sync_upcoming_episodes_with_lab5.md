# 20261104121500-sync-upcoming-episodes-with-lab5

Синхронізовано таблицю `upcoming_episodes` зі схемою лаб. 5.

**Зміни:**
- Додано сурогатний ключ `upcoming_episode_id UUID PRIMARY KEY DEFAULT uuidv7()`
- Видалено складений PK `(anime_id, episode_name)` → додано `UNIQUE(anime_id, episode_name)`
- Додано CHECK constraint: `length(trim(episode_name)) > 0`

**Було:**
```prisma
model UpcomingEpisode {
  animeId     String   @map("anime_id") @db.Uuid
  episodeName String   @map("episode_name")
  episodeDate DateTime @default(now()) @map("episode_date")

  anime      Anime    @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@id([animeId, episodeName])
  @@index([episodeDate], map: "idx_upcoming_episode_date")
  @@map("upcoming_episodes")
}
```

**Стало:**
```prisma
model UpcomingEpisode {
  upcomingEpisodeId UUID     @id @default(uuid()) @map("upcoming_episode_id") @db.Uuid
  animeId           String   @map("anime_id") @db.Uuid
  episodeName       String   @map("episode_name")
  episodeDate       DateTime @default(now()) @map("episode_date")

  anime             Anime    @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@unique([animeId, episodeName])
  @@index([episodeDate], map: "idx_upcoming_episode_date")
  @@map("upcoming_episodes")
}
```

## Prisma Studio

[alt text](image-10.png)
