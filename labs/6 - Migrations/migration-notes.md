# Лабораторна робота №6 — Міграції БД (Prisma ORM)

## Налаштування та стартова міграція

Проєкт працює з PostgreSQL (база `shop_lab6`, 11 таблиць і 5 `ENUM`-типів із 5-ї лаби) та Prisma `7.10.1`. Налаштування підключення винесено в `prisma7.config.ts`, а для роботи клієнта підключено адаптер `@prisma/adapter-pg` та драйвер `pg`. Локальний файл `.env` зі справжнім паролем приховано через `.gitignore`, натомість у репозиторій додано шаблон `.env.example`.

Щоб підв'язати Prisma до вже існуючої бази з даними без їх видалення:

1. Зчитали структуру таблиць у `prisma/schema.prisma` командою `npx prisma db pull`.
2. Створили початкову міграцію `0_init`:
   ```bash
   npx prisma migrate diff --from-empty --to-schema prisma/schema.prisma --script --output prisma/migrations/0_init/migration.sql
   ```
3. Позначили її як уже застосовану:
   ```bash
   npx prisma migrate resolve --applied 0_init
   ```

> **Примітка щодо CHECK-обмежень:** Prisma не підтримує опис `CHECK` у `schema.prisma`, тому обмеження з 5-ї лаби (формат `email`, `price >= 0`, `discount` у межах 0–100, статуси доставки) не потрапили в `0_init/migration.sql`, хоча в самій базі `shop_lab6` вони збереглися. Для нової таблиці `review` перевірку `CHECK` дописали вручну через `--create-only`.

## Як запустити проєкт після клонування

Попередньо потрібна PostgreSQL з базою `shop_lab6`, створеною скриптом із Лаб. 5: у ній є тестові дані, які використовує `test.ts` (на порожній базі скрипт завершується помилкою `У базі немає тестових товарів або клієнтів`).

Папка `generated/prisma` виключена з репозиторію через `.gitignore`, тому клієнт Prisma потрібно згенерувати:

1. Встановіть залежності:
   ```bash
   npm install
   ```
2. Створіть файл `.env` на основі шаблону `.env.example` і вкажіть свій рядок підключення `DATABASE_URL`.
3. Якщо база щойно створена скриптом Лаб. 5 (історії міграцій у ній ще немає), позначте базову міграцію застосованою та застосуйте решту:
   ```bash
   npx prisma migrate resolve --applied 0_init
   npx prisma migrate deploy
   ```
4. Згенеруйте клієнт Prisma:
   ```bash
   npx prisma generate
   ```
5. Запустіть скрипт перевірки:
   ```bash
   npx tsx test.ts
   ```

## Виконані міграції

### 1. Нова таблиця відгуків (`20261122191818_add_review_table`)

Додали таблицю `review`, щоб клієнти могли залишати оцінки (від 1 до 5) та коментарі до товарів. Спочатку згенерували чернетку міграції:

```bash
npx prisma migrate dev --create-only --name add-review-table
```

Потім додали в кінець SQL-файлу обмеження `CHECK (rating >= 1 AND rating <= 5)` і застосували міграцію:

```bash
npx prisma migrate dev
```

Для зовнішніх ключів у `review` обрали `ON DELETE CASCADE` (на відміну від `NO ACTION` у таблицях замовлень чи платежів), оскільки сам по собі відгук не має сенсу без товару або клієнта.

**Було (`prisma/schema.prisma`).** Після нормалізації в 5-й лабі модель `client` має зв'язок лише з `address[]`, оскільки замовлення `orders` прив'язані до адреси доставки:

```prisma
model client {
  client_id    Int       @id @default(autoincrement())
  client_name  String    @db.VarChar(32)
  last_name    String    @db.VarChar(32)
  email        String    @db.VarChar(32)
  phone_number String?   @db.VarChar(20)
  address      address[]
}
```

**Стало (`prisma/schema.prisma`).** Додано модель `review` та зворотні зв'язки `review review[]` у моделях `client` і `product`:

```prisma
model review {
  review_id  Int      @id @default(autoincrement())
  rating     Int
  comment    String?  @db.VarChar(500)
  created_at DateTime @default(now()) @db.Timestamptz(6)
  product_id Int
  client_id  Int
  product    product  @relation(fields: [product_id], references: [product_id], onDelete: Cascade, onUpdate: NoAction)
  client     client   @relation(fields: [client_id], references: [client_id], onDelete: Cascade, onUpdate: NoAction)
}
```

**SQL (`prisma/migrations/20261122191818_add_review_table/migration.sql`):**

```sql
-- CreateTable
CREATE TABLE "review" (
    "review_id" SERIAL NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" VARCHAR(500),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "product_id" INTEGER NOT NULL,
    "client_id" INTEGER NOT NULL,

    CONSTRAINT "review_pkey" PRIMARY KEY ("review_id")
);

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("product_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "client"("client_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- Custom CHECK constraint
ALTER TABLE "review" ADD CONSTRAINT "review_rating_check" CHECK (rating >= 1 AND rating <= 5);
```

### 2. Додавання поля `is_featured` у `product` (`20261122192619_add_product_featured_flag`)

Додали прапорець `is_featured` (за замовчуванням `false`), щоб виділяти рекомендовані товари на головній сторінці. Поле відповідає за промо-відображення і не дублює `stock_status` (наявність товару на складі), тому нормалізацію з 5-ї лаби не порушує.

Команда:

```bash
npx prisma migrate dev --name add-product-featured-flag
```

**Було:**

```prisma
model product {
  product_id   Int               @id @default(autoincrement())
  product_name String
  price        Decimal           @db.Decimal(10, 2)
  quantity     Int
  description  String            @db.VarChar(255)
  stock_status stock_status_name
  image_url    String?
  category_id  Int
  ...
}
```

**Стало:**

```prisma
model product {
  product_id   Int               @id @default(autoincrement())
  product_name String
  price        Decimal           @db.Decimal(10, 2)
  quantity     Int
  description  String            @db.VarChar(255)
  stock_status stock_status_name
  image_url    String?
  is_featured  Boolean           @default(false)
  category_id  Int
  ...
}
```

**SQL (`prisma/migrations/20261122192619_add_product_featured_flag/migration.sql`):**

```sql
-- AlterTable
ALTER TABLE "product" ADD COLUMN "is_featured" BOOLEAN NOT NULL DEFAULT false;
```

### 3. Видалення стовпця `image_url` (`20261122192822_drop_product_image_url`)

Видалили стовпець `image_url` із таблиці `product` (він був доданий ще в 1-й лабі, тут прибрали для демонстрації міграції з видаленням колонки). Під час запуску:

```bash
npx prisma migrate dev --name drop-product-image-url
```

Prisma попередила, що в колонці є 3 заповнені значення, які зітруться. Дію підтвердили вручну (`y`).

**Було:**

```prisma
  stock_status stock_status_name
  image_url    String?
  is_featured  Boolean           @default(false)
```

**Стало:**

```prisma
  stock_status stock_status_name
  is_featured  Boolean           @default(false)
```

**SQL (`prisma/migrations/20261122192822_drop_product_image_url/migration.sql`):**

```sql
-- AlterTable
ALTER TABLE "product" DROP COLUMN "image_url";
```

## Перевірка роботи

### Статус міграцій (`npx prisma migrate status`)

```text
4 migrations found in prisma/migrations

Database schema is up to date!
```

### Скрипт перевірки (`test.ts`)

```ts
import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from './generated/prisma/client';

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});
const prisma = new PrismaClient({ adapter });

async function main() {
  const product = await prisma.product.findFirst();
  const client = await prisma.client.findFirst();

  if (!product || !client) {
    throw new Error('У базі немає тестових товарів або клієнтів');
  }

  // 1. Перевірка Міграції №2 (поле is_featured)
  const updatedProduct = await prisma.product.update({
    where: { product_id: product.product_id },
    data: { is_featured: true },
  });
  console.log('Оновлений товар (is_featured):', {
    id: updatedProduct.product_id,
    name: updatedProduct.product_name,
    is_featured: updatedProduct.is_featured,
  });

  // 2. Перевірка Міграції №1 (створення запису в новій таблиці review)
  const review = await prisma.review.create({
    data: {
      rating: 5,
      comment: 'Чудовий товар, швидка доставка!',
      product_id: product.product_id,
      client_id: client.client_id,
    },
  });
  console.log('Створений відгук:', review);

  // 3. Запит пов'язаних записів через include (product -> review)
  const withReviews = await prisma.product.findMany({
    where: { review: { some: {} } },
    include: { review: true },
  });
  console.log('Товари з відгуками (include):');
  console.log(JSON.stringify(withReviews, null, 2));

  // 4. Перевірка CHECK-обмеження (рейтинг 10 має відхилитися базою PostgreSQL)
  try {
    await prisma.review.create({
      data: {
        rating: 10,
        comment: 'Невалідний рейтинг',
        product_id: product.product_id,
        client_id: client.client_id,
      },
    });
    console.log('ПОМИЛКА: рейтинг 10 збережено!');
  } catch (e) {
    console.log('Відхилено базою:', (e as Error).message);
  }
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
```

### Вивід у терміналі (`npx tsx test.ts`)

Примітки до виводу:
- `review_id` збільшився з `1` до `3`, оскільки невдала спроба вставки з `rating: 10` під час першого запуску використала значення `2` з послідовності `SERIAL` до того, як рядок було відхилено обмеженням `CHECK`. Це штатна поведінка PostgreSQL.
- У другому запуску `findFirst()` повернув товар №2: запит без сортування не гарантує порядок рядків.

```text
Оновлений товар (is_featured): { id: 2, name: 'Ноутбук "ThinkPad X2"', is_featured: true }
Створений відгук: {
  review_id: 3,
  rating: 5,
  comment: 'Чудовий товар, швидка доставка!',
  created_at: 2026-11-22T19:44:26.142Z,
  product_id: 2,
  client_id: 1
}
Товари з відгуками (include):
[
  {
    "product_id": 1,
    "product_name": "Смартфон \"Galaxy S30\"",
    "price": "29999",
    "quantity": 50,
    "description": "Флагманський смартфон з покращеною камерою",
    "stock_status": "in_stock",
    "is_featured": true,
    "category_id": 1,
    "review": [
      {
        "review_id": 1,
        "rating": 5,
        "comment": "Чудовий товар, швидка доставка!",
        "created_at": "2026-11-22T19:30:30.018Z",
        "product_id": 1,
        "client_id": 1
      }
    ]
  },
  {
    "product_id": 2,
    "product_name": "Ноутбук \"ThinkPad X2\"",
    "price": "45000",
    "quantity": 25,
    "description": "Потужний ноутбук для бізнесу",
    "stock_status": "in_stock",
    "is_featured": true,
    "category_id": 1,
    "review": [
      {
        "review_id": 3,
        "rating": 5,
        "comment": "Чудовий товар, швидка доставка!",
        "created_at": "2026-11-22T19:44:26.142Z",
        "product_id": 2,
        "client_id": 1
      }
    ]
  }
]
Відхилено базою: 
Invalid `prisma.review.create()` invocation in
C:\Users\lenovo\Desktop\БД\Lab6\test.ts:50:25

  47 
  48 // 4. Перевірка CHECK-обмеження (рейтинг 10 має відхилитися базою PostgreSQL)
  49 try {
→ 50   await prisma.review.create(
Database error. Code: `23514`. Message: `новий рядок для відношення "review" порушує перевірне обмеження перевірку "review_rating_check"`
```