# 20261103195645_init_upcoming_episodes

Створено таблицю `upcoming_episodes` (модель `UpcomingEpisode`) з полями upcoming_episode_id, anime_id, episode_name, episode_date. Додано сурогатний первинний ключ (upcoming_episode_id), унікальний ключ (anime_id, episode_name) та зовнішній ключ на animes(anime_id).

**Було:**
```prisma
// таблиця upcoming_episodes відсутня
```

**Стало:**
```prisma
model UpcomingEpisode {
  animeId     String   @map("anime_id") @db.Uuid
  episodeName String   @map("episode_name")
  episodeDate DateTime @default(now()) @map("episode_date")

  anime      Anime    @relation(fields: [animeId], references: [animeId])

  @@id([animeId, episodeName])
  @@map("upcoming_episodes")
}
```


## Prisma Studio
![alt text](image-2.png)
