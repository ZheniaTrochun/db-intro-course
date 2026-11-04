# 20261104081400_list_units_grade_field_to_smallint

Змінено таблицю anime_list_units
шляхом зміни рядка grade
так щоб у базі даних він був типу SmallInt.

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
  grade Int? @db.SmallInt

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)
  user User @relation(fields: [userId], references: [userId], onDelete: Cascade)

  @@id([userId, animeId])
  @@map("anime_list_units")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/43451049-16fb-48fb-a008-bda5cbdc81cf/-/preview/509x428/)
