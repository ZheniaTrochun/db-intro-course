# 20261104083519_users_new_fields_and_enums

Змінено таблицю `users`. Створено enum `user_role_enum` (user, admin) та колонку `user_role` (default `user`), у яку перенесено користувачів зі статусом `admin`. Enum `user_status_enum` перебудовано: значення `admin` замінено на `active`, а колонку `user_status` зроблено `NOT NULL` з default `active` (існуючі `admin` та `NULL` перетворено на `active`). Додано колонку `streak_start_date`. Колонку `crated_at` перейменовано на `created_at`, а `created_at` та `updated_at` змінено на `TIMESTAMPTZ(6)`. Видалено індекс `idx_nickname`. Додано `CHECK`-обмеження `users_max_streak_check` та `check_user_auth_method` (потрібен `password_hash` або `google_id`), які Prisma не підтримує в схемі, тому вони додані вручну в SQL міграції.

**Було:**
```prisma
enum UserStatusEnum {
  admin
  banned
  deactivated

  @@map("user_status_enum")
}

model User {
  userId               String          @id @default(dbgenerated("uuidv7()")) @map("user_id") @db.Uuid
  nickname             String          @unique @db.VarChar(30)
  fullName             String          @map("full_name") @db.VarChar(100)
  email                String          @unique
  googleId             String?         @unique @map("google_id")
  bio                  String          @default("")
  passwordHash         String?         @map("password_hash")
  avatarUrl            String?         @map("avatar_url")
  socialNetworks       String[]        @default([]) @map("social_networks")
  maxStreak            Int             @default(0) @map("max_streak")
  timezone             String          @default("UTC")
  lastWatchDate        DateTime?       @map("last_watch_date") @db.Date
  profileFrameUrl      String?         @map("profile_frame_url")
  profileBackgroundUrl String?         @map("profile_background_url")
  userStatus           UserStatusEnum? @map("user_status")
  cratedAt             DateTime        @default(now()) @map("crated_at") @db.Timestamp(6)
  updatedAt            DateTime        @default(now()) @map("updated_at") @db.Timestamp(6)

  @@index([userStatus], map: "idx_user_status")
  @@index([nickname], map: "idx_nickname")
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

## Prisma Studio

![Скріншот з Prisma Studio](https://1snd12r3e2.ucarecd.net/c0c5bde1-eb4b-41dd-a56b-aa08b25a9e33/noroot.png)
