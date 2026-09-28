# ТЗ: Лабораторна робота 6 — Міграції схеми через Prisma ORM

## Мета
Розвинути схему PostgreSQL з лаб. 5 за допомогою Prisma: `db pull`, зміни схеми, міграції, перевірка через Prisma Client / Studio.

## Що зробити

1. **Ініціалізація Prisma**
   ```bash
   npm init -y
   npm install prisma --save-dev
   npx prisma init --datasource-provider postgresql
   ```
   - у `.env` вказати `DATABASE_URL` на існуючу БД з лаб. 5.

2. **Аналіз наявної схеми**
   ```bash
   npx prisma db pull
   ```
   - переконатися, що в `schema.prisma` з'явилися моделі для таблиць з лаб. 5;
   - **закомітити** початкову схему та зміни `.env`.

3. **Зміни схеми** (кожна зміна ізольована, окрема міграція)

   | Зміна | Приклад | Міграція |
   |-------|---------|----------|
   | **Нова таблиця** | модель `Review` із зв'язком до `Product` | `add-review-table` |
   | **Зміна таблиці** | додати поле (напр. `inStock Boolean @default(true)`) або перейменувати (у Prisma це drop + add) | `add-product-field` |
   | **Видалення** | видалити стовпець або зв'язок | `drop-old-column` |

4. **Застосування міграцій**
   ```bash
   npx prisma migrate dev --name add-review-table
   npx prisma migrate dev --name add-product-field
   npx prisma migrate dev --name drop-old-column
   ```
   - на кожну зміну своя міграція, з чіткою назвою (напр. `add-email-to-user`);
   - SQL-файли з'являться в `prisma/migrations/`.

5. **Перевірка через Prisma Client**
   - варіант A: `npx prisma studio` (вставити/переглянути дані у вебінтерфейсі);
   - варіант B: короткий Node.js-скрипт з `@prisma/client`, який вставляє рядок (`create`) і читає зв'язані дані (`findMany` з `include`);
   - запити мають виконуватися без помилок, дані відображатися коректно.

6. **Додатково (за бажанням)**: повторно запустити `npx prisma db pull` і звірити фінальну схему з БД.

## Поради

- Ключове слово `model` для таблиць, `@relation` для зв'язків.
- **Комітити** `prisma/schema.prisma` і всю `prisma/migrations/` (разом із `migration_lock.toml`).
- Не потрібно писати застосунок чи API (ні Express, ні фронтенд): лише схема та перевірка даних.

## Що здати

| № | Результат | Вимоги |
|---|-----------|--------|
| 1 | **`prisma/schema.prisma`** | оновлена схема з усіма змінами |
| 2 | **`prisma/migrations/`** | по підпапці на міграцію, з SQL-файлами |
| 3 | **`migration-notes.md`** (допускається pdf/docx) | для кожної міграції: що змінено, фрагменти «до/після» (модель Prisma або SQL), запити Prisma Client або скріншоти |
| 4 | **Доказ роботи** | скрипт Node.js **або** скріншот Prisma Studio з успішною вставкою/вибіркою в нових чи змінених таблицях |
| 5 | **Відправка** | усе в **Git-репозиторій** групи: `prisma/`, `migration-notes.md`, тестові скрипти, скріншоти |

## Матеріали

- Prisma ORM Guide (prisma.io/docs/orm)
- Medium: NestJS Backend Project Stage 1 (Cansu Sancar)
- Mindbowser: Node, Prisma ORM & PostgreSQL REST API guide
