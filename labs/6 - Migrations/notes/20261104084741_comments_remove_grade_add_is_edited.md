# 20261104084741_comments_remove_grade_add_is_edited

Змінено таблицю `comments`. Видалено колонку `grade`, додано колонку `is_edited` (BOOLEAN, default false). Тип `created_at` змінено на `TIMESTAMPTZ(6)`. Індекс `idx_comments_anime_id` замінено на складений індекс `idx_comments_anime_created` по `(anime_id, comment_id DESC)`. Додано `CHECK`-обмеження `comments_content_check`, яке забороняє порожній текст коментаря (воно додане вручну в SQL, бо Prisma його не підтримує).

**Було:**
```prisma
model Comment {
  commentId BigInt   @id @default(autoincrement()) @map("comment_id")
  authorId  String   @map("author_id") @db.Uuid
  animeId   String   @map("anime_id") @db.Uuid
  grade     Int?     @db.SmallInt
  content   String
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamp(6)

  author User  @relation(fields: [authorId], references: [userId], onDelete: Cascade)
  anime  Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId], map: "idx_comments_anime_id")
  @@map("comments")
}
```

**Стало:**
```prisma
model Comment {
  commentId BigInt   @id @default(autoincrement()) @map("comment_id")
  authorId  String   @map("author_id") @db.Uuid
  animeId   String   @map("anime_id") @db.Uuid
  content   String
  createdAt DateTime @default(now()) @map("created_at") @db.Timestamptz(6)
  isEdited  Boolean  @default(false) @map("is_edited")

  author User  @relation(fields: [authorId], references: [userId], onDelete: Cascade)
  anime  Anime @relation(fields: [animeId], references: [animeId], onDelete: Cascade)

  @@index([animeId, commentId(sort: Desc)], map: "idx_comments_anime_created")
  @@map("comments")
}
```

## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/edeb4a40-ccbe-462f-8907-d0458199e198/noroot.png)
