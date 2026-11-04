# 20261104110000-rename-index-upcoming-episodes

Перейменовано індекс `idx_upcoming_episodes_date` → `idx_upcoming_episode_date` у таблиці `upcoming_episodes` для узгодженості зі звітом нормалізації (лаб. 5).

**Було:**
```prisma
@@index([episodeDate], map: "idx_upcoming_episodes_date")
```

**Стало:**
```prisma
@@index([episodeDate], map: "idx_upcoming_episode_date")
```

## Prisma Studio

[Скріншот з Prisma Studio](![alt text](image-5.png))
