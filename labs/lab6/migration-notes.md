# Звіт про міграції схеми бази даних (Лабораторна робота №6)

**Виконавці:** Бабенко Ярослав, Резніков Нікіта (група ІМ-55)  
**СУБД та інструменти:** PostgreSQL (Docker), Prisma ORM, Prisma Studio  
**Початкова схема:** 6 основних моделей (`person`, `poem`, `review`, `collection`, `collection_poem`, `poem_author`), зчитаних з PostgreSQL за допомогою `npx prisma db pull`.

---

## Загальна структура міграцій

Усі зміни схеми було розбито на 4 ізольовані міграції з метою забезпечення простежуваності історії бази даних та збереження цілісності даних.

---

## Частина 1. Міграції Бабенка

### Міграція 1: `add_tag_system`
* **Опис:** Реалізовано систему тегування поетичних творів. Додано довідник тегів `tag` та зв'язуючу таблицю `poem_tag` для організації зв'язку «багато-до-багатьох» (M:N) із моделлю `poem`.

#### Код схеми Prisma до змін:
```prisma
// Моделі tag та poem_tag відсутні в schema.prisma.
model poem {
  poem_id       Int             @id @default(autoincrement())
  owner_id      Int
  title         String          @db.VarChar(150)
  content_poem  String
  created_at    DateTime        @default(now()) @db.Timestamp(6)
  person        person          @relation(fields: [owner_id], references: [person_id], onDelete: Cascade, onUpdate: NoAction)
  collection_poem collection_poem[]
  poem_author   poem_author[]
  review        review[]
}
```

#### Код схеми Prisma після змін:
```prisma
model tag {
  tag_id      Int        @id @default(autoincrement())
  name        String     @unique @db.VarChar(50)
  description String?    @db.VarChar(200)
  created_at  DateTime   @default(now()) @db.Timestamp(6)
  poem_tag    poem_tag[]
}

model poem_tag {
  poem_id     Int
  tag_id      Int
  assigned_at DateTime @default(now()) @db.Timestamp(6)
  poem        poem     @relation(fields: [poem_id], references: [poem_id], onDelete: Cascade, onUpdate: NoAction)
  tag         tag      @relation(fields: [tag_id], references: [tag_id], onDelete: Cascade, onUpdate: NoAction)

  @@id([poem_id, tag_id])
}

model poem {
  poem_id       Int             @id @default(autoincrement())
  owner_id      Int
  title         String          @db.VarChar(150)
  content_poem  String
  created_at    DateTime        @default(now()) @db.Timestamp(6)
  person        person          @relation(fields: [owner_id], references: [person_id], onDelete: Cascade, onUpdate: NoAction)
  collection_poem collection_poem[]
  poem_author   poem_author[]
  poem_tag      poem_tag[]
  review        review[]
}
```

---

### Міграція 2: `extend_poem_and_person`
* **Опис:** Розширено модель `poem` посиланнями на статистику переглядів, рекомендації та мову (`views_count`, `is_featured`, `language` із дефолтними значеннями), а також додано поле біографії користувача `bio` у модель `person`.

#### Код схеми Prisma до змін:
```prisma
model person {
  person_id     Int      @id @default(autoincrement())
  username      String   @unique @db.VarChar(50)
  email         String   @unique @db.VarChar(100)
  password_hash String   @db.VarChar(255)
  created_at    DateTime @default(now()) @db.Timestamp(6)
  // ...
}

model poem {
  poem_id       Int      @id @default(autoincrement())
  owner_id      Int
  title         String   @db.VarChar(150)
  content_poem  String
  created_at    DateTime @default(now()) @db.Timestamp(6)
  // ...
}
```

#### Код схеми Prisma після змін:
```prisma
model person {
  person_id     Int      @id @default(autoincrement())
  username      String   @unique @db.VarChar(50)
  email         String   @unique @db.VarChar(100)
  password_hash String   @db.VarChar(255)
  bio           String?  @db.VarChar(300)
  created_at    DateTime @default(now()) @db.Timestamp(6)
  // ...
}

model poem {
  poem_id       Int      @id @default(autoincrement())
  owner_id      Int
  title         String   @db.VarChar(150)
  content_poem  String
  views_count   Int      @default(0)
  is_featured   Boolean  @default(false)
  language      String   @default("uk") @db.VarChar(10)
  created_at    DateTime @default(now()) @db.Timestamp(6)
  // ...
}
```

---

## Частина 2. Міграції Резнікова

### Міграція 3: `add_bookmark_table`
* **Опис:** Створено таблицю закладок `bookmark` з унікальним обмеженням `@@unique([user_id, poem_id])` для уникнення дублювання та каскадним видаленням при вилученні користувача або вірша.

#### Код схеми Prisma до змін:
```prisma
// Модель bookmark відсутня в schema.prisma
```

#### Код схеми Prisma після змін:
```prisma
model bookmark {
  bookmark_id Int      @id @default(autoincrement())
  user_id     Int
  poem_id     Int
  note        String?  @db.VarChar(255)
  is_favorite Boolean  @default(false)
  created_at  DateTime @default(now()) @db.Timestamp(6)
  person      person   @relation(fields: [user_id], references: [person_id], onDelete: Cascade, onUpdate: NoAction)
  poem        poem     @relation(fields: [poem_id], references: [poem_id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([user_id, poem_id])
}

// Зворотні зв'язки у суміжних моделях:
// model person { ... bookmark bookmark[] }
// model poem   { ... bookmark bookmark[] }
```

---

### Міграція 4: `refine_review_and_collection`
* **Опис:** Оптимізовано структуру відгуків та колекцій: з моделі `review` видалено неактуальне поле `comment`, а до моделі `collection` додано текстовий опис `description` та часову мітку оновлення `updated_at`.

#### Код схеми Prisma до змін:
```prisma
model review {
  user_id    Int
  poem_id    Int
  rating     Int
  comment    String?
  updated_at DateTime @default(now()) @db.Timestamp(6)
  person     person   @relation(fields: [user_id], references: [person_id], onDelete: Cascade, onUpdate: NoAction)
  poem       poem     @relation(fields: [poem_id], references: [poem_id], onDelete: Cascade, onUpdate: NoAction)

  @@id([user_id, poem_id])
}

model collection {
  collection_id   Int               @id @default(autoincrement())
  person_id       Int
  title           String            @db.VarChar(150)
  created_at      DateTime          @default(now()) @db.Timestamp(6)
  // ...
}
```

#### Код схеми Prisma після змін:
```prisma
model review {
  user_id    Int
  poem_id    Int
  rating     Int
  updated_at DateTime @default(now()) @db.Timestamp(6)
  person     person   @relation(fields: [user_id], references: [person_id], onDelete: Cascade, onUpdate: NoAction)
  poem       poem     @relation(fields: [poem_id], references: [poem_id], onDelete: Cascade, onUpdate: NoAction)

  @@id([user_id, poem_id])
}

model collection {
  collection_id   Int               @id @default(autoincrement())
  person_id       Int
  title           String            @db.VarChar(150)
  description     String?           @db.VarChar(255)
  created_at      DateTime          @default(now()) @db.Timestamp(6)
  updated_at      DateTime          @default(now()) @db.Timestamp(6)
  // ...
}
```

---

## Результати перевірки в Prisma Studio

Усі згенеровані міграції успішно застосовані до PostgreSQL та протестовані на цілісність даних через інтерактивний веб-інтерфейс **Prisma Studio** (`http://localhost:51212`).

### 1. Підтвердження міграцій Бабенка
Створено тестові записи в таблицях `person`, `poem`, `tag` та зв'язуючій таблиці `poem_tag`. Перевірено заповнення полів за замовчуванням (`views_count = 0`, `is_featured = false`, `language = "uk"`).

![Prisma Studio — Перевірка міграцій Бабенка](./studio-babenko.png)

### 2. Підтвердження міграцій Резнікова
Додано запис у нову таблицю `bookmark`, перевірено відображення поля `description` у `collection` та підтверджено видалення поля `comment` із таблиці `review`.

![Prisma Studio — Перевірка міграцій Резнікова](./studio-reznikov.png)

---

## Висновки
У ході лабораторної роботи було опановано інструментарій **Prisma ORM** для управління міграціями бази даних PostgreSQL:
1. За допомогою `npx prisma db pull` виконано реверс-інжиніринг існуючої схеми.
2. Створено та послідовно застосовано 4 міграції за допомогою `npx prisma migrate dev`.
3. Зафіксовано повну відповідність фізичної бази даних декларативним моделям у `schema.prisma`.