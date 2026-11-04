# 20261104102452_users_migrate_social_networks_to_links

Змінено таблицю `users` та виконано міграцію даних. Значення `social_networks` перенесено в таблицю `user_links` (по одному рядку на посилання, дублікати ігноруються), після чого колонку `social_networks` видалено. Колонку `avatar_url` зроблено `NOT NULL` з default `''` (наявні `NULL` перед цим замінено на `''`). Default для `timezone` змінено на `Europe/Kyiv`. Індекс `idx_user_status` перейменовано на `idx_users_status`. Звичайні унікальні обмеження `users_nickname_key` та `users_email_key` замінено функціональними унікальними індексами `idx_users_unique_lower_nickname` та `idx_users_unique_lower_email` по `lower(...)`, щоб нікнейми й пошти були унікальними без урахування регістру. Prisma не вміє описувати такі індекси, тому `@unique` у схемі прибрано, а індекси додано вручну в SQL.

**Було:**
```prisma
enum UserStatusEnum {
  active
  banned
  deactivated

  @@map("user_status_enum")
}

enum UserRoleEnum {
  user
  admin

  @@map("user_role_enum")
}

model User {
  userId               String         @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String         @unique @db.VarChar(30)
  fullName             String         @map("full_name") @db.VarChar(100)
  email                String         @unique
  googleId             String?        @unique @map("google_id")
  bio                  String         @default("")
  passwordHash         String?        @map("password_hash")
  avatarUrl            String?        @map("avatar_url")
  socialNetworks       String[]       @default([]) @map("social_networks")
  maxStreak            Int            @default(0) @map("max_streak")
  timezone             String         @default("UTC")
  streakStartDate      DateTime?      @map("streak_start_date") @db.Date
  lastWatchDate        DateTime?      @map("last_watch_date") @db.Date
  profileFrameUrl      String?        @map("profile_frame_url")
  profileBackgroundUrl String?        @map("profile_background_url")
  userRole             UserRoleEnum   @default(user) @map("user_role")
  userStatus           UserStatusEnum @default(active) @map("user_status")
  createdAt            DateTime       @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt            DateTime       @default(now()) @map("updated_at") @db.Timestamptz(6)

  comments       Comment[]
  animeListUnits AnimeListUnit[]
  sessions       Session[]

  @@index([userStatus], map: "idx_user_status")
  @@map("users")
}
```

**Стало:**
```prisma
enum UserStatusEnum {
  active
  banned
  deactivated

  @@map("user_status_enum")
}

enum UserRoleEnum {
  user
  admin

  @@map("user_role_enum")
}

model User {
  userId               String         @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String         @db.VarChar(30)
  fullName             String         @map("full_name") @db.VarChar(100)
  email                String
  googleId             String?        @unique @map("google_id")
  bio                  String         @default("")
  passwordHash         String?        @map("password_hash")
  avatarUrl            String         @default("") @map("avatar_url")
  maxStreak            Int            @default(0) @map("max_streak")
  timezone             String         @default("Europe/Kyiv")
  streakStartDate      DateTime?      @map("streak_start_date") @db.Date
  lastWatchDate        DateTime?      @map("last_watch_date") @db.Date
  profileFrameUrl      String?        @map("profile_frame_url")
  profileBackgroundUrl String?        @map("profile_background_url")
  userRole             UserRoleEnum   @default(user) @map("user_role")
  userStatus           UserStatusEnum @default(active) @map("user_status")
  createdAt            DateTime       @default(now()) @map("created_at") @db.Timestamptz(6)
  updatedAt            DateTime       @default(now()) @map("updated_at") @db.Timestamptz(6)

  comments       Comment[]
  animeListUnits AnimeListUnit[]
  sessions       Session[]
  userLinks      UserLink[]

  @@index([userStatus], map: "idx_users_status")
  @@map("users")
}
```

## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/f2ad3172-5e7a-4939-8d73-355ae22137dd/noroot.png)
