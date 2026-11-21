# Лабораторна робота 6. Міграції схеми Wishlist

База Wishlist з лабораторної 5 уже існувала в PostgreSQL на `localhost:5432` (база `postgres`). Prisma підключилась до неї, зчитала таблиці командою `npx prisma db pull` і далі змінювала схему трьома окремими міграціями.

Початкові таблиці: `users`, `wishlists`, `wishlist_items`, `reservations`.

Після всіх міграцій у схемі з'явилась таблиця `comments`, у `wishlist_items` з'явилась колонка `priority`, а колонка `image_url` видалена.

Рядок підключення DATABASE_URL лежить у `.env`

## 0. Початкова схема після `db pull`

`npx prisma db pull` записав чотири моделі в `prisma/schema.prisma`. Окрім колонок Prisma додала поля зв'язку (`wishlists wishlists[]`, `reservations reservations[]` тощо).

Фрагмент `wishlist_items` одразу після зчитування:

```prisma
model wishlist_items {
  item_id      String        @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  wishlist_id  String        @db.Uuid
  name         String        @db.VarChar(150)
  description  String?
  price        Decimal       @db.Decimal(10, 2)
  product_url  String?
  image_url    String?
  is_completed Boolean       @default(false)
  reservations reservations?
  wishlists    wishlists     @relation(fields: [wishlist_id], references: [wishlist_id], onDelete: Cascade, onUpdate: NoAction)
}
```

Prisma попередила, що не переносить `CHECK (price >= 0)` у файл схеми. Обмеження в базі залишилось, його назва — `wishlist_items_price_check`.

## 1. Міграція `0_init`

База вже містила таблиці, а історії міграцій Prisma ще не було. Перший `prisma migrate dev` у такій ситуації зупиняється. Тому поточну схему зафіксовано як уже застосовану базову міграцію.

У кінець `prisma/migrations/0_init/migration.sql` вручну додано перевірку ціни, бо `migrate diff` її не генерує:

```sql
ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_price_check" CHECK (price >= 0);
```

Ця міграція нових таблиць не створювала.

## 2. Міграція `20261121152904_add_comments_table`

Додано модель `comments`: коментар належить одному товару зі списку бажань. Зворотне поле `comments comments[]` додано в `wishlist_items`, інакше Prisma не приймає зв'язок.

Після:

```prisma
model comments {
  comment_id     String         @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  item_id        String         @db.Uuid
  author_name    String         @db.VarChar(100)
  rating         Int
  text           String?
  created_at     DateTime       @default(now()) @db.Timestamp(6)
  wishlist_items wishlist_items @relation(fields: [item_id], references: [item_id], onDelete: Cascade, onUpdate: NoAction)
}
```

```prisma
model wishlist_items {
  // ...колонки без змін...
  reservations reservations?
  wishlists    wishlists     @relation(fields: [wishlist_id], references: [wishlist_id], onDelete: Cascade, onUpdate: NoAction)
  comments     comments[]
}
```

SQL міграції:

```sql
CREATE TABLE "comments" (
    "comment_id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "item_id" UUID NOT NULL,
    "author_name" VARCHAR(100) NOT NULL,
    "rating" INTEGER NOT NULL,
    "text" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "comments_pkey" PRIMARY KEY ("comment_id")
);

ALTER TABLE "comments" ADD CONSTRAINT "comments_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "wishlist_items"("item_id") ON DELETE CASCADE ON UPDATE NO ACTION;
```

## 3. Міграція `20261121153017_add_item_priority`

У `wishlist_items` додано пріоритет товару. Значення за замовчуванням `0`, тож існуючі рядки заповнились без ручного оновлення.

До:

```prisma
  product_url  String?
  image_url    String?
  is_completed Boolean       @default(false)
```

Після:

```prisma
  product_url  String?
  image_url    String?
  is_completed Boolean       @default(false)
  priority     Int           @default(0)
```

SQL міграції:

```sql
ALTER TABLE "wishlist_items" ADD COLUMN "priority" INTEGER NOT NULL DEFAULT 0;
```

## 4. Міграція `20261121153105_drop_image_url`

З `wishlist_items` видалено необов'язкову колонку `image_url`. Зовнішніх ключів на неї не було.

До:

```prisma
  product_url  String?
  image_url    String?
  is_completed Boolean       @default(false)
  priority     Int           @default(0)
```

Після:

```prisma
  product_url  String?
  is_completed Boolean       @default(false)
  priority     Int           @default(0)
```

SQL міграції:

```sql
ALTER TABLE "wishlist_items" DROP COLUMN "image_url";
```

## 5. Підсумкова модель `wishlist_items`

```prisma
model wishlist_items {
  item_id      String        @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  wishlist_id  String        @db.Uuid
  name         String        @db.VarChar(150)
  description  String?
  price        Decimal       @db.Decimal(10, 2)
  product_url  String?
  is_completed Boolean       @default(false)
  priority     Int           @default(0)
  reservations reservations?
  wishlists    wishlists     @relation(fields: [wishlist_id], references: [wishlist_id], onDelete: Cascade, onUpdate: NoAction)
  comments     comments[]
}
```

## 6. Перевірка через Prisma Client

Скрипт `labs/6 - Migrations/check-comments.ts` бере перший товар із `wishlist_items`, створює для нього коментар і читає всі товари разом із коментарями. `include: { comments: true }` не фільтрує рядки: у відповідь потрапляє кожен товар, а коментарі дописуються вкладеним масивом. Якщо коментарів немає, масив порожній.

Команда:

```bash
npx tsx "labs/6 - Migrations/check-comments.ts"
```

Вивід:

```text
[
  {
    "item_id": "88a6f4d8-f4ea-4479-8973-769d3bedd0d0",
    "wishlist_id": "04784996-1c31-4a1f-b1aa-48161a156cbc",
    "name": "Wireless Headphones",
    "description": "Noise cancelling headphones",
    "price": "199.99",
    "product_url": "https://example.com/headphones",
    "is_completed": false,
    "priority": 0,
    "comments": [
      {
        "comment_id": "8d1b3a1b-2592-4cfe-bbda-8ecc79ba2928",
        "item_id": "88a6f4d8-f4ea-4479-8973-769d3bedd0d0",
        "author_name": "Олена",
        "rating": 5,
        "text": "Саме те, що хотіла",
        "created_at": "2026-11-21T15:39:12.785Z"
      },
      {
        "comment_id": "d025b461-4c63-4fbd-b344-3f7a6df99b18",
        "item_id": "88a6f4d8-f4ea-4479-8973-769d3bedd0d0",
        "author_name": "Олена",
        "rating": 5,
        "text": "Саме те, що хотіла",
        "created_at": "2026-11-21T15:56:22.606Z"
      }
    ]
  },
  {
    "item_id": "b61ae141-f7cf-433f-b04f-3a4f300f80b9",
    "wishlist_id": "04784996-1c31-4a1f-b1aa-48161a156cbc",
    "name": "Coffee Machine",
    "description": "Automatic coffee machine",
    "price": "349",
    "product_url": "https://example.com/coffee-machine",
    "is_completed": false,
    "priority": 0,
    "comments": []
  },
  {
    "item_id": "28b74e30-f4c0-482a-941f-d963bb34bc53",
    "wishlist_id": "e0f1404f-d1cc-481e-ba97-20fd1bae28b7",
    "name": "Clean Code",
    "description": "Book about software craftsmanship",
    "price": "45.5",
    "product_url": "https://example.com/clean-code",
    "is_completed": true,
    "priority": 0,
    "comments": [
      {
        "comment_id": "f538eff7-eaef-4983-9fd2-9950d815bf4f",
        "item_id": "28b74e30-f4c0-482a-941f-d963bb34bc53",
        "author_name": "Dude",
        "rating": 5,
        "text": "Good",
        "created_at": "2026-11-21T15:33:46.273Z"
      }
    ]
  },
  {
    "item_id": "d457430c-f863-4c36-8f43-5d2a2cc02ee1",
    "wishlist_id": "61f1460d-2965-412e-88ed-9a3fde52ab30",
    "name": "Mechanical Keyboard",
    "description": "Mechanical keyboard for programming",
    "price": "120",
    "product_url": "https://example.com/keyboard",
    "is_completed": false,
    "priority": 0,
    "comments": []
  },
  {
    "item_id": "6f1643f2-8c2a-445a-9045-aa6a42975924",
    "wishlist_id": "61f1460d-2965-412e-88ed-9a3fde52ab30",
    "name": "USB-C Hub",
    "description": "Multi-port USB-C adapter",
    "price": "59.99",
    "product_url": "https://example.com/usb-hub",
    "is_completed": false,
    "priority": 0,
    "comments": []
  }
]
```
