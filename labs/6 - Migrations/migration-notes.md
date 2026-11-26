# Лабораторна робота 6: Міграції схеми за допомогою Prisma ORM

**Проєкт:** Logistics WMS (`logistics`, PostgreSQL 18)  
**Інструмент:** Prisma ORM 6.19.3 (classic engine), Node.js 22  
**База даних:** `postgresql://postgres:***@localhost:5432/logistics?schema=public`  
**Корінь проєкту:** `C:\Users\arosl\OneDrive\Рабочий стол\BD`

## 1. Підготовка середовища

```bash
npm init -y
npm install prisma@6 @prisma/client@6 --save-dev
npx prisma init --datasource-provider postgresql
```

У `.env` вказано `DATABASE_URL` до існуючої бази `logistics`. У `prisma/schema.prisma`
генератор змінено на класичний клієнт:

```prisma
generator client {
  provider = "prisma-client-js"
}
```

Перед стартом база була приведена до нормалізованої схеми лабораторної 5
(перенесено `batch_number` з `supply_item` у `supply_order` скриптом
`docs/lab5/migration_batch_to_order.sql`).

## 2. Аналіз існуючої схеми (baseline)

```bash
npx prisma db pull
```

Prisma зчитав 7 таблиць (`supplier`, `product`, `warehouse_location`, `supply_order`,
`supply_item`, `inventory_stock`, `inventory_movement`), 3 enum-типи та індекси.
Оскільки база вже існувала, створено baseline-міграцію без виконання:

```bash
npx prisma migrate diff --from-empty --to-schema-datamodel=prisma/schema.prisma --script \
  -o prisma/migrations/0000_baseline/migration.sql
npx prisma migrate resolve --applied 0000_baseline
```

Перевірка:

```text
npx prisma migrate status
5 migrations found in prisma/migrations
Database schema is up to date!
```

(на момент написання звіту міграцій 5: baseline + 4 нижче.)

## 3. Внесені зміни схеми

Зміни обрано під домен WMS (складський облік), а не копіюють приклад з методички
(Product/Review). Використано патерн **expand and contract** (лекція 9, розд. 4):
спочатку додаємо нову колонку і копіюємо дані, потім видаляємо стару.

### Міграція 1. `20261119222714_add_product_notes`

**Що змінилося:** у `product` додано колонку `notes TEXT` (nullable).  
**Чому:** перехід від `description` до `notes` без downtime; старий код ще читає `description`.

Prisma SQL:

```sql
-- Зміна таблиці
ALTER TABLE "product" ADD COLUMN "notes" TEXT;

-- Міграція даних: копіюємо старий description у нову колонку notes (крок expand)
UPDATE "product" SET "notes" = "description" WHERE "notes" IS NULL;
```

**Безпечність:** додавання nullable-колонки — безпечна (швидка) ALTER-операція
(лекція 9, розд. 1). `UPDATE` виконано в тій же транзакції, що й DDL, тому
зміна схеми і даних атомарна (PostgreSQL підтримує транзакційний DDL).

До:

```prisma
model product {
  product_id      Int    @id @default(autoincrement())
  sku_code        String @unique @db.VarChar(50)
  name            String @db.VarChar(100)
  description     String?
  unit            unit_type @default(piece)
  min_stock_level Int    @default(0)
}
```

Після:

```prisma
model product {
  product_id      Int    @id @default(autoincrement())
  sku_code        String @unique @db.VarChar(50)
  name            String @db.VarChar(100)
  description     String?
  notes           String?
  unit            unit_type @default(piece)
  min_stock_level Int    @default(0)
}
```

### Міграція 2. `20261119222733_add_product_category`

**Що змінилося:** створено нову таблицю `product_category` і додано nullable FK
`product.category_id` (ON DELETE SET NULL).

Prisma SQL:

```sql
ALTER TABLE "product" ADD COLUMN "category_id" INTEGER;

CREATE TABLE "product_category" (
    "category_id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "product_category_pkey" PRIMARY KEY ("category_id")
);

CREATE UNIQUE INDEX "product_category_name_key" ON "product_category"("name");
CREATE INDEX "idx_product_category_name" ON "product_category"("name");
CREATE INDEX "idx_product_category" ON "product"("category_id");

ALTER TABLE "product" ADD CONSTRAINT "product_category_id_fkey"
  FOREIGN KEY ("category_id") REFERENCES "product_category"("category_id")
  ON DELETE SET NULL ON UPDATE NO ACTION;
```

**Безпечність:** нова таблиця і nullable FK не блокують існуючі записи; міграція
застосовується без downtime. FK має `ON DELETE SET NULL`, щоб видалення категорії
не ламало товари.

До: таблиці `product_category` не було, зв'язку `product -> category` не було.  
Після: з'явилася модель:

```prisma
model product_category {
  category_id   Int       @id @default(autoincrement())
  name          String    @unique @db.VarChar(100)
  description   String?
  created_at    DateTime  @default(now()) @db.Timestamp(6)
  product       product[]
}
```

### Міграція 3. `20261119222748_add_product_reorder_quantity`

**Що змінилося:** у `product` додано `reorder_quantity INTEGER NOT NULL DEFAULT 0`.

Prisma SQL:

```sql
ALTER TABLE "product" ADD COLUMN "reorder_quantity" INTEGER NOT NULL DEFAULT 0;
```

**Безпечність:** додавання колонки з DEFAULT — безпечна операція в PostgreSQL 11+
(default зберігається в метаданих, таблиця не переписується). Використано для
параметра автозамовлення товару (min stock / reorder point), що розширює домен WMS.

### Міграція 4. `20261119222800_drop_product_description`

**Що змінилося:** видалено колонку `product.description` (contract-крок патерну).

Prisma SQL:

```sql
ALTER TABLE "product" DROP COLUMN "description";
```

**Безпечність:** видалення колонки — швидка операція (лекція 9), але незворотна.
Виконано лише після того, як дані скопійовано у `notes` (міграція 1), тому
інформація не втрачена. У реальному робочому процесі перед цим кроком
випускається версія ПЗ, що читає `notes` замість `description`.

## 4. Фінальна схема (фрагмент `product`)

```prisma
model product {
  product_id       Int               @id @default(autoincrement())
  sku_code         String            @unique @db.VarChar(50)
  name             String            @db.VarChar(100)
  notes            String?
  unit             unit_type         @default(piece)
  min_stock_level  Int               @default(0)
  reorder_quantity Int               @default(0)
  category_id      Int?
  product_category product_category? @relation(fields: [category_id], references: [category_id], onDelete: SetNull, onUpdate: NoAction)
  inventory_movement inventory_movement[]
  inventory_stock    inventory_stock[]
  supply_item        supply_item[]

  @@index([category_id], map: "idx_product_category")
}
```

## 5. Перевірка клієнтом Prisma

Скрипт: `docs/lab6/lab6_client_test.js`. Запуск:

```bash
node docs/lab6/lab6_client_test.js
```

Вивід:

```text
Created category: { category_id: 1, name: 'Кабелі та конектори', ... }
Updated product: { product_id: 1, sku_code: 'SKU-UTP-5E', notes: 'Бухта 305м', reorder_quantity: 5, category: 'Кабелі та конектори' }
Products in category: [ 'SKU-UTP-5E (Кабелі та конектори)' ]
Cleanup done.
```

Скрипт перевіряє: вставку в нову таблицю `product_category`, оновлення товару
з призначенням категорії/`reorder_quantity`, читання зв'язку `product -> product_category`,
очищення тестових даних. Усі запити виконались без помилок.

## 6. Зв'язок з лекцією 9 (ALTER та міграції)

- **Безпечні vs небезпечні ALTER:** у міграціях використано лише безпечні
  операції (ADD COLUMN nullable/with default, CREATE TABLE, ADD FK nullable,
  DROP COLUMN). Небезпечні (ADD NOT NULL/CHECK на існуючі дані, зміна типу,
  CREATE INDEX без CONCURRENTLY) не застосовувались.
- **Версіонування і незмінність:** кожна зміна — окрема міграція з унікальним
  timestamp-ім'ям у `prisma/migrations/`; після застосування файли не змінюються
  (roll forward, а не rollback).
- **Транзакційність DDL:** PostgreSQL виконує кожну міграцію в одній транзакції;
  зміна схеми і data-migration (backfill `notes`) застосовані атомарно.
- **Expand and contract:** `description -> notes` виконано двома кроками
  (додати+скопіювати, потім видалити стару), що дозволяє без downtime переходити
  між версіями ПЗ.
- **Міграція даних:** окрім DDL, міграція 1 містить `UPDATE` для backfill.
- **Базова таблиця версій:** Prisma веде `_prisma_migrations` (аналог
  `schema_migrations` з лекції 9) з версією, checksum і часом виконання.
- **Незмінність міграцій:** файли `migration.sql` не редагуються після застосування,
  бо будь-яка зміна (навіть коментаря) змінює checksum і Prisma вважає міграцію
  `modified after it was applied`. Тому стандартні англомовні коментарі Prisma
  у файлах `migration.sql` залишено без змін; переклад виконано у цьому звіті.
- **Міграція 4** створена вручну (папка з timestamp і `migration.sql`), оскільки
  `prisma migrate dev` у неінтерактивному режимі зупиняється на підтвердженні
  видалення колонки з даними. SQL повністю відповідає зміні схеми Prisma.

## 6.1 Перевірка через psql

Запуск (повний шлях до `psql.exe`, оскільки у PATH його не було):

```bash
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d logistics -c "\d product"
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d logistics -c "\dt"
```

Вивід підтвердив: колонки `notes`, `category_id`, `reorder_quantity`; відсутність `description`; наявність таблиці `product_category`; FK `product_category_id_fkey ... ON DELETE SET NULL`.

## 7. Файли, що додаються до Git

- `prisma/schema.prisma`
- `prisma/migrations/` (усі 5 підпапок з `migration.sql` + `migration_lock.toml`)
- `prisma.config.ts`, `package.json`, `package-lock.json`
- `docs/lab6/lab6_client_test.js`
- `migration-notes.md`

`.env` не комітиться (містить пароль БД).

## 8. Чек-лист відповідності вимогам лабораторної

- [x] Ініціалізація Prisma у папці проєкту (`npm init`, `npm install prisma --save-dev`, `npx prisma init --datasource-provider postgresql`).
- [x] `DATABASE_URL` вказує на існуючу БД PostgreSQL (`logistics`).
- [x] `npx prisma db pull` виконано, схема зчитана в `prisma/schema.prisma`.
- [x] Початкова схема зафіксована в Git (baseline-міграція `0000_baseline`).
- [x] Додано нову таблицю (`product_category`) зі зв'язком до `product`.
- [x] Змінено наявну таблицю: додано `notes`, `reorder_quantity`, `category_id`.
- [x] Видалено стовпець (`product.description`) окремою міграцією (contract-крок).
- [x] Зміни ізольовані, кожна міграція має чітку назву.
- [x] Міграції застосовані через `prisma migrate dev`, статус `up to date`.
- [x] Папка `prisma/` (schema + migrations + lock) у Git.
- [x] Перевірка клієнтом Prisma: вставка/читання в нових і змінених таблицях (`docs/lab6/lab6_client_test.js`).
- [x] `migration-notes.md` з описом кожної міграції і фрагментами до/після.
- [x] Використано матеріали лекції 9: безпечні/небезпечні ALTER, версіонування, незмінність, транзакційний DDL, expand and contract, data migration, roll forward.
- [x] Повторна перевірка виконана через psql (`\d product`, `\dt`): фінальна схема і таблиця `product_category` підтверджені.

## 9. Висновки

- Підключено Prisma ORM до існуючої БД `logistics` через `db pull`.
- Створено baseline-міграцію без втрати даних (`migrate resolve --applied`).
- Виконано 4 еволюційні міграції: backfill-колонка `notes`, нова таблиця
  `product_category` + FK, `reorder_quantity`, видалення застарілої `description`.
- Усі міграції застосовано (`migrate status`: up to date), клієнт Prisma
  успішно вставляє/читає дані в нових таблицях.
- Підхід узгоджений з лекцією 9: версіонування, незмінність, атомарність DDL,
  expand and contract, розрізнення безпечних і небезпечних ALTER.
