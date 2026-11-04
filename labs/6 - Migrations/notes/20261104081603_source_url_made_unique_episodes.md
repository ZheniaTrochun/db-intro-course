# 20261104081603_source_url_made_unique_episodes

Змінено таблицю episodes
шляхом додавання Unique
на поле source_url.

**Було:**
```prisma
model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType String? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```

**Стало:**
```prisma
model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @unique @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType String? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/c71a8523-86f2-4a87-8eb7-3cc0e48d18dc/20261104104450_hyprshot.png)
