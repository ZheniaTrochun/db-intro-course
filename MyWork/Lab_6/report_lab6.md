<div style="text-align: center; font-size: 22px; margin-top: 60px;">

Міністерство освіти і науки України

Національний технічний університет України

«Київський політехнічний інститут імені Ігоря Сікорського»

Факультет інформатики та обчислювальної техніки

Кафедра обчислювальної техніки

</div>

<div style="text-align: center; margin-top: 120px;">

<h1 style="font-size: 30px;">Лабораторна робота №6</h1>

<h2 style="font-size: 24px;">з дисципліни «Бази даних»</h2>

</div>

<div style="text-align: right; margin-top: 120px; font-size: 18px;">

<strong>Виконав:</strong><br>
Степаненко Денис<br>
студент групи ІМ-051<br>
номер у списку групи: 16<br><br>

<strong>Перевірив:</strong><br>
Хмельницький Арсеній Андрійович

</div>

<div style="text-align: center; margin-top: 120px; font-size: 22px;">

Київ 2026

</div>

---

## Короткий виклад вимог

**Завдання:**

Використати Prisma ORM для роботи з базою даних VideoHub. Описати схему в `schema.prisma`, створити міграції для зміни схеми, перевірити результат через Prisma Studio.

**Що таке Prisma ORM:**

Prisma — Object-Relational Mapping (ORM) інструмент для Node.js/TypeScript. Замість написання SQL-запитів вручну, Prisma генерує типобезпечний клієнт з `schema.prisma`. Міграції автоматично створюють SQL для зміни структури БД.

**Що таке міграція:**

Міграція — контрольована зміна структури БД. Prisma порівнює `schema.prisma` з поточним станом БД і генерує SQL-файл з потрібними змінами (CREATE TABLE, ALTER TABLE, DROP). Кожна міграція зберігається в `prisma/migrations/` — це історія змін схеми.

**Поняття:**

- **schema.prisma** — декларативний опис моделей БД (аналог SQL CREATE TABLE, але зручніший)
- **prisma migrate dev** — команда для створення та застосування міграції
- **prisma generate** — генерація TypeScript-клієнта з schema.prisma
- **prisma studio** — GUI для перегляду та редагування даних
- **@relation** — опис зв'язку між моделями (FK)
- **@map** — мапінг імені поля в БД (наприклад, `authorId` → `author_id`)

---

## Ініціалізація Prisma

Створюємо Node.js-проєкт з Prisma:

```json
{
  "name": "videohub-prisma",
  "version": "1.0.0",
  "devDependencies": {
    "prisma": "^6.0.0"
  },
  "dependencies": {
    "@prisma/client": "^6.0.0"
  }
}
```

Підключення до PostgreSQL через `.env`:

```
DATABASE_URL="postgresql://postgres:5643@localhost:5432/videohub?schema=public"
```

---

## schema.prisma — початкова схема

Описуємо моделі VideoHub (User, Video, Comment, Like, Subscription):

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id           String   @id @default(uuid()) @db.Uuid
  email        String   @unique
  username     String   @unique
  password     String?
  googleId     String?  @unique
  description  String?
  avatar       String?
  banner       String?
  createdAt    DateTime @default(now()) @map("created_at")

  videos       Video[]
  comments     Comment[]
  likes        Like[]
  subscribers  Subscription[] @relation("SubscriberRelation")
  subscriptions Subscription[] @relation("SubscribedToRelation")

  @@map("User")
}

model Video {
  id          String   @id @default(uuid()) @db.Uuid
  title       String
  description String?
  url         String
  thumbnail   String?
  views       Int      @default(0)
  createdAt   DateTime @default(now()) @map("created_at")
  authorId    String   @map("author_id") @db.Uuid

  author      User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  comments    Comment[]
  likes       Like[]

  @@map("Video")
}

model Comment {
  id        String   @id @default(uuid()) @db.Uuid
  text      String
  createdAt DateTime @default(now()) @map("created_at")
  userId    String   @map("user_id") @db.Uuid
  videoId   String   @map("video_id") @db.Uuid

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  video     Video    @relation(fields: [videoId], references: [id], onDelete: Cascade)

  @@map("Comment")
}

model Like {
  id        String   @id @default(uuid()) @db.Uuid
  createdAt DateTime @default(now()) @map("created_at")
  userId    String   @map("user_id") @db.Uuid
  videoId   String   @map("video_id") @db.Uuid

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  video     Video    @relation(fields: [videoId], references: [id], onDelete: Cascade)

  @@unique([userId, videoId])

  @@map("Like")
}

model Subscription {
  id              String   @id @default(uuid()) @db.Uuid
  createdAt       DateTime @default(now()) @map("created_at")
  subscriberId    String   @map("subscriber_id") @db.Uuid
  subscribedToId  String   @map("subscribed_to_id") @db.Uuid

  subscriber      User     @relation("SubscriberRelation", fields: [subscriberId], references: [id], onDelete: Cascade)
  subscribedTo    User     @relation("SubscribedToRelation", fields: [subscribedToId], references: [id], onDelete: Cascade)

  @@unique([subscriberId, subscribedToId])

  @@map("Subscription")
}
```

**Особливості schema.prisma:**

- `@id @default(uuid())` — первинний ключ, авто-генерація UUID
- `@db.Uuid` — тип колонки в PostgreSQL (UUID)
- `@unique` — унікальне обмеження
- `@map("column_name")` — мапінг імені поля (camelCase в коді → snake_case в БД)
- `@@map("table_name")` — мапінг імені таблиці
- `@@unique([field1, field2])` — складене унікальне обмеження
- `@relation(fields: [fk], references: [pk], onDelete: Cascade)` — зв'язок FK
- `String?` — nullable поле (знак питання)

---

## Міграція 1: init

Початкова схема — створення всіх таблиць VideoHub:

```bash
npx prisma migrate dev --name init
```

Prisma генерує SQL-файл `migration.sql`:

```sql
CREATE TABLE "User" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "email" VARCHAR(255) NOT NULL,
    "username" VARCHAR(100) NOT NULL,
    "password" VARCHAR(255),
    "google_id" VARCHAR(255),
    "description" TEXT,
    "avatar" VARCHAR(500),
    "banner" VARCHAR(500),
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Video" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "url" VARCHAR(500) NOT NULL,
    "thumbnail" VARCHAR(500),
    "views" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "author_id" UUID NOT NULL,
    CONSTRAINT "Video_pkey" PRIMARY KEY ("id")
);

-- ... Comment, Like, Subscription аналогічно

-- Унікальні індекси
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");
CREATE UNIQUE INDEX "Like_user_id_video_id_key" ON "Like"("user_id", "video_id");

-- Зовнішні ключі
ALTER TABLE "Video" ADD CONSTRAINT "Video_author_id_fkey"
    FOREIGN KEY ("author_id") REFERENCES "User"("id") ON DELETE CASCADE;
```

---

## Міграція 2: add-video-duration

Додаємо поле `duration` (тривалість відео в секундах) до моделі Video:

```prisma
model Video {
  // ... існуючі поля
  duration    Int?     @map("duration")    // нове поле
}
```

```bash
npx prisma migrate dev --name add_video_duration
```

Згенерований SQL:

```sql
ALTER TABLE "Video" ADD COLUMN "duration" INTEGER;
```

`Int?` — nullable (не всі відео мають відому тривалість при завантаженні). `ALTER TABLE ADD COLUMN` додає колонку до існуючої таблиці без втрати даних.

---

## Міграція 3: add-video-category

Додаємо таблицю `Category` та зв'язок Video → Category (M:1):

```prisma
model Category {
  id    Int    @id @default(autoincrement())
  name  String @unique

  videos Video[]

  @@map("Category")
}

model Video {
  // ... існуючі поля
  category    Category? @relation(fields: [categoryId], references: [id])
  categoryId  Int?      @map("category_id")    // нове поле FK
}
```

```bash
npx prisma migrate dev --name add_video_category
```

Згенерований SQL:

```sql
CREATE TABLE "Category" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "Category_name_key" ON "Category"("name");

ALTER TABLE "Video" ADD COLUMN "category_id" INTEGER;

ALTER TABLE "Video" ADD CONSTRAINT "Video_category_id_fkey"
    FOREIGN KEY ("category_id") REFERENCES "Category"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;
```

`Category?` — nullable FK (відео може не мати категорії). `ON DELETE SET NULL` — при видаленні категорії, `category_id` відео стає NULL (не видаляється відео). `@default(autoincrement())` — автоінкремент для id категорії (SERIAL в PostgreSQL).

---

## Prisma Studio

Перевірка даних через Prisma Studio — GUI для перегляду та редагування:

```bash
npx prisma studio
```

Prisma Studio відкривається в браузері на порту 5555. Показує всі таблиці з `schema.prisma`, дозволяє переглядати, додавати, редагувати та видаляти записи.

---

## Скріншоти

### schema.prisma — опис моделей VideoHub (частина 1: generator, datasource, User)

<div style="text-align: center;">

<img src="screenshots/schema_prisma_1.png" alt="schema.prisma — generator, datasource, модель User" style="width: 100%; max-width: 800px;">

</div>

### schema.prisma — моделі Video, Comment, Like (частина 2)

<div style="text-align: center;">

<img src="screenshots/schema_prisma_2.png" alt="schema.prisma — моделі Video, Comment, Like" style="width: 100%; max-width: 800px;">

</div>

### schema.prisma — моделі Subscription, Category (частина 3)

<div style="text-align: center;">

<img src="screenshots/schema_prisma_3.png" alt="schema.prisma — моделі Subscription, Category" style="width: 100%; max-width: 800px;">

</div>

### Міграція 1 — init: CREATE TABLE (частина 1)

<div style="text-align: center;">

<img src="screenshots/migration_init_1.png" alt="Міграція init — CREATE TABLE (частина 1)" style="width: 100%; max-width: 800px;">

</div>

### Міграція 1 — init: індекси та зовнішні ключі (частина 2)

<div style="text-align: center;">

<img src="screenshots/migration_init_2.png" alt="Міграція init — індекси та FK (частина 2)" style="width: 100%; max-width: 800px;">

</div>

### Міграція 2 — add-video-duration (ALTER TABLE)

<div style="text-align: center;">

<img src="screenshots/migration_duration.png" alt="Міграція add_video_duration — ALTER TABLE" style="width: 100%; max-width: 800px;">

</div>

### Міграція 3 — add-video-category (нова таблиця + FK)

<div style="text-align: center;">

<img src="screenshots/migration_category.png" alt="Міграція add_video_category — Category + FK" style="width: 100%; max-width: 800px;">

</div>

### Prisma Studio — таблиця User з даними

<div style="text-align: center;">

<img src="screenshots/prisma_studio_users.png" alt="Prisma Studio — таблиця User" style="width: 100%; max-width: 800px;">

</div>

### Prisma Studio — таблиця Like з даними

<div style="text-align: center;">

<img src="screenshots/prisma_studio_likes.png" alt="Prisma Studio — таблиця Like" style="width: 100%; max-width: 800px;">

</div>

---

## Походження бази даних

База даних **VideoHub** була взята з реального проєкту — відеохостинг-платформи на стеку Next.js + Prisma + PostgreSQL. Проєкт знаходиться в розробці, і схема БД продовжує дороблюватись в процесі проходження лабораторних робіт.

**Як БД використовувалась у лабораторних:**

- **Lab 1** — концептуальна модель (ER-діаграма) на основі схеми VideoHub
- **Lab 2** — DDL: фізична схема в PostgreSQL (CREATE TABLE, INSERT) на основі Prisma-схеми проєкту
- **Lab 3** — OLTP: CRUD-операції (SELECT, INSERT, UPDATE, DELETE) на тестових даних
- **Lab 4** — OLAP: агрегація, GROUP BY, HAVING, JOIN на тестових даних
- **Lab 5** — нормалізація: перевірка схеми на 1NF, 2NF, 3NF, виправлення через ALTER TABLE
- **Lab 6** — Prisma ORM: опис схеми в `schema.prisma`, міграції, Prisma Studio

**Тестові дані:**

Для тестування БД використовувались тестові дані з файлу `prisma/seed.sql` — 5 користувачів, 5 відео, 5 коментарів, 5 лайків, 5 підписок. Ці дані дозволяють перевірити всі операції (CRUD, агрегацію, JOIN, нормалізацію) на реалістичних прикладах.

| Таблиця | Кількість | Приклади |
|---------|-----------|----------|
| User | 5 | denys_dev, maria_gaming, oleg_cook, anna_travel, max_music |
| Video | 5 | PostgreSQL Tutorial, Elden Ring, Pasta Carbonara, Tokyo, Wonderwall |
| Comment | 5 | коментарі до відео різних авторів |
| Like | 5 | лайки між користувачами |
| Subscription | 5 | підписки між користувачами |

**Чому БД з проєкту, а не з нуля:**

Використання реальної схеми проєкту дає кілька переваг:
- Схема відповідає реальним вимогам і вже нормалізована
- Тестові дані реалістичні (користувачі, відео, коментарі)
- Лабораторні роботи логічно пов'язані — кожна наступна будується на попередній
- Prisma-схема з проєкту використовується як основа для Lab 6

---

## Будь які припущення чи обмеження

- `DATABASE_URL` містить облікові дані PostgreSQL. В реальному проєкті `.env` не комітиться в Git (в `.gitignore`). Для лабораторної створено `.env.example` з прикладом.

- `@map` та `@@map` використовуються для мапінгу camelCase (Prisma/TypeScript) → snake_case (PostgreSQL). Наприклад, `authorId` в коді → `author_id` в БД.

- `onDelete: Cascade` на @relation — при видаленні батьківського запису автоматично видаляються дочірні (як ON DELETE CASCADE в SQL з Lab 2).

- `ON DELETE SET NULL` на Video→Category — при видаленні категорії відео не видаляється, `category_id` стає NULL. Це безпечніше за CASCADE для категорій.

- `@default(autoincrement())` для Category.id — SERIAL в PostgreSQL, автоінкремент. На відміну від UUID, числовий id зручніший для категорій (невеликий справочник).

- Prisma migrate dev автоматично: 1) порівнює schema.prisma з БД, 2) генерує SQL-міграцію, 3) застосовує до БД, 4) генерує клієнт. В продакшені використовується `prisma migrate deploy` (без генерації).

- Міграції зберігаються в `prisma/migrations/` — це історія змін схеми. Кожна міграція має timestamp + name + migration.sql. Дозволяє відкотити зміни або відтворити схему на новій БД.
