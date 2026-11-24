# Lab 6 — Міграції схем (Prisma ORM)

## 🇺🇦 Українською

Управління схемою БД через **міграції Prisma ORM**: декларативна схема в `schema.prisma` (моделі, відношення, `@map`/`@@map`, `onDelete: Cascade`/`SetNull`) і три версійовані міграції — `init` → додано `Video.duration` → додано `Category` з `ON DELETE SET NULL`. Плюс `seed.sql` для наповнення та Prisma Studio як GUI-переглядач.

### Файли

- `prisma/schema.prisma` — моделі User, Video, Comment, Like, Subscription, Category
- `prisma/migrations/` — три міграції з SQL-файлами
- `prisma/seed.sql` — тестові дані (5 користувачів, відео, коментарі, лайки, підписки)
- `package.json` — залежності та seed-конфігурація
- `.env.example` — шаблон `DATABASE_URL` (реальний `.env` у `.gitignore`)
- `tasks.md` — завдання лабораторної
- `report_lab6.md` / `report_lab6.pdf` — звіт
- `screenshots/` — Prisma Studio та migrate-команди

---

## 🇬🇧 English

Database schema management via **Prisma ORM migrations**: a declarative `schema.prisma` (models, relations, `@map`/`@@map`, `onDelete: Cascade`/`SetNull`) and three versioned migrations — `init` → added `Video.duration` → added `Category` with `ON DELETE SET NULL`. Plus `seed.sql` for test data and Prisma Studio as a GUI browser.

### Files

- `prisma/schema.prisma` — User, Video, Comment, Like, Subscription, Category models
- `prisma/migrations/` — three migrations with SQL files
- `prisma/seed.sql` — test data (5 users, videos, comments, likes, subscriptions)
- `package.json` — dependencies and seed configuration
- `.env.example` — `DATABASE_URL` template (real `.env` is gitignored)
- `tasks.md` — lab assignment
- `report_lab6.md` / `report_lab6.pdf` — report
- `screenshots/` — Prisma Studio and migrate commands
