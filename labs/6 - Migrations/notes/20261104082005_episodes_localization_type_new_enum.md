# 20261104082005_episodes_localization_type_new_enum

Створено/змінено таблицю episodes
шляхом зміни рядка localization_type
так щоб його значення було прив'язане до новоствореного enum.

**Було:**
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

**Стало:**
```prisma
enum EpisodeLocalizationType {
  sub
  dub

  @@map("episode_localization_type_enum")
}

model Episode {
  episodeId BigInt @id @default(autoincrement()) @map("episode_id")
  animeId String @map("anime_id") @db.Uuid
  sourceUrl String @unique @map("source_url")
  episodeName String @map("episode_name")
  localizationStudio String @default("") @map("localization_studio")
  localizationType EpisodeLocalizationType? @map("localization_type")

  anime Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_episodes_anime_id")
  @@map("episodes")
}
```


## Prisma Studio

![Скріншот з Prisma Studio](https://ucarecdn.com/0dd81694-7bd4-4555-b1b9-fc032277c7c0/20261104104742_hyprshot.png)
