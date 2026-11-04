# 20261103200712_init_anime_list_units

Створено таблицю anime_list_units
з рядками grade, watched_episodes, started_watching, anime_id, user_id, list_unit_status

**Було:**
```prisma
```

**Стало:**
```prisma
enum AnimeListUnitStatus {
  finished
  watching
  delayed
  dropped

  @@map("anime_list_unit_status_enum")
}

model AnimeListUnit {
  userId String @map("user_id") @db.Uuid
  animeId String @map("anime_id") @db.Uuid
  watchedEpisodes Int @default(0) @map("watched_episodes")
  startedWatching DateTime @default(dbgenerated("(now())::date")) @map("started_watching") @db.Date
  listUnitStatus AnimeListUnitStatus @default(watching) @map("list_unit_status")
  grade Int?

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/27894ed1-e876-4568-91f8-36efb6c97aeb/-/preview/315x236/)
