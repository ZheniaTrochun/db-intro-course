# 20261103201850_new_repeat_times_field_for_list_units

Змінено таблицю anime_list_units
шляхом додавання рядка repeat_times

**Було:**
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
  repeatTimes Int @default(0) @map("repeat_times")
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

![Скріншот з Prisma Studio](https://ucarecdn.com/cd750aec-4d2d-4d45-a514-b1d5a71a0706/-/preview/455x391/)
