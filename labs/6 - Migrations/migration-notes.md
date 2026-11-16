# Лабораторна робота 6: Міграції схем за допомогою Prisma ORM

**Середовище:** Prisma 7.10.0, Bun, PostgreSQL (`localhost:5433`, база `postgres`).
**Предметна область:** система обліку відвідувань та інцидентів (студенти, візити, інциденти, співробітники охорони).

---

## 1. Ініціалізація Prisma

```bash
bun add -d prisma
bunx prisma init --datasource-provider postgresql
```

Створено `prisma/schema/schema.prisma` та `.env`. У `.env` змінна `DATABASE_URL` вказує на існуючу базу PostgreSQL з лабораторної роботи 5. У Prisma 7 адреса бази задається не в `schema.prisma`, а в конфігураційному файлі `prisma7.config.ts`:

```ts
import "dotenv/config";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: { path: "prisma/migrations" },
  datasource: { url: env("DATABASE_URL") },
});
```

---

## 2. Аналіз існуючої схеми (`prisma db pull`)

```bash
bunx prisma db pull
```

Під час першого запуску Prisma знайшла лише **8 моделей**: у базі лишалася схема до нормалізації (таблиця `student` містила і `group_id`, і `faculty_id`, а таблиць `faculty` та `student_group` не було). Після застосування міграційного SQL-скрипта з лабораторної роботи 5 (створення `faculty` і `student_group`, перенесення даних, видалення `student.faculty_id`) повторний `db pull` дав **10 моделей**: `faculty`, `student_group`, `student`, `visit`, `security_employee`, `incident_type`, `incident_status`, `participant_role`, `incident`, `incident_participant`.

**Обмеження Prisma.** Під час інтроспекції Prisma попередила, що не підтримує CHECK-обмеження, тому вони не потрапили в `schema.prisma`:

- `incident`: `chk_incident_severity`
- `visit`: `chk_visit_dates`

Ці обмеження залишаються лише на рівні SQL, а в міграціях Prisma їх немає.

---

## 3. Початкова міграція `init`

База вже містила таблиці, але історії міграцій у Prisma не було. Команда `prisma migrate dev` виявила розбіжність (drift) і запропонувала скинути схему:

```
Drift detected: Your database schema is not in sync with your migration history.
We need to reset the "public" schema at "localhost:5433"
```

Тому виконано скидання та створення початкової міграції з поточної схеми:

```bash
bunx prisma migrate reset --force
bunx prisma migrate dev --name init
```

Результат: `prisma/migrations/20261116202651_init/migration.sql` створює всі 10 таблиць (початок файлу):

```sql
-- CreateTable
CREATE TABLE "incident" (
    "incident_id" SERIAL NOT NULL,
    "visit_id" INTEGER NOT NULL,
    "type_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "status_id" INTEGER NOT NULL DEFAULT 1,
    "description" TEXT,
    "occurred_at" TIMESTAMP(6) NOT NULL,
    "severity" VARCHAR(20) NOT NULL,

    CONSTRAINT "incident_pkey" PRIMARY KEY ("incident_id")
);
-- ... решта таблиць, унікальні індекси та зовнішні ключі
```

Далі кожна зміна схеми виконана окремою міграцією.

---

## 4. Міграція 1: `add_incident_comment_table` (нова таблиця)

**Що змінено:** додано таблицю `incident_comment` для коментарів співробітників охорони до інцидентів. Таблиця пов'язана з `incident` та `security_employee`.

**До:** таблиці `incident_comment` не існувало.

**Після (`schema.prisma`):**

```prisma
model incident_comment {
  comment_id        Int               @id @default(autoincrement())
  incident_id       Int
  employee_id       Int
  text              String
  created_at        DateTime          @default(now()) @db.Timestamp(6)
  incident          incident          @relation(fields: [incident_id], references: [incident_id], onDelete: NoAction, onUpdate: NoAction, map: "fk_comment_incident")
  security_employee security_employee @relation(fields: [employee_id], references: [employee_id], onDelete: NoAction, onUpdate: NoAction, map: "fk_comment_employee")
}
```

У моделі `incident` та `security_employee` додано зворотне поле `incident_comment incident_comment[]`.

```bash
bunx prisma migrate dev --name add-incident-comment-table
```

**Згенерований SQL** (`20261116203101_add_incident_comment_table`):

```sql
-- CreateTable
CREATE TABLE "incident_comment" (
    "comment_id" SERIAL NOT NULL,
    "incident_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "incident_comment_pkey" PRIMARY KEY ("comment_id")
);

-- AddForeignKey
ALTER TABLE "incident_comment" ADD CONSTRAINT "fk_comment_incident" FOREIGN KEY ("incident_id") REFERENCES "incident"("incident_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident_comment" ADD CONSTRAINT "fk_comment_employee" FOREIGN KEY ("employee_id") REFERENCES "security_employee"("employee_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
```

---

## 5. Міграція 2: `add_employee_email` (нове поле в існуючій таблиці)

**Що змінено:** у `security_employee` додано необов'язкове унікальне поле `email`.

**До:**

```prisma
model security_employee {
  employee_id Int    @id @default(autoincrement())
  full_name   String @db.VarChar(150)
  position    String @db.VarChar(100)
  phone       String @unique @db.VarChar(20)
}
```

**Після:**

```prisma
model security_employee {
  employee_id Int     @id @default(autoincrement())
  full_name   String  @db.VarChar(150)
  position    String  @db.VarChar(100)
  phone       String  @unique @db.VarChar(20)
  email       String? @unique @db.VarChar(150)
}
```

```bash
bunx prisma migrate dev --name add-employee-email
```

**Згенерований SQL** (`20261116203247_add_employee_email`):

```sql
-- AlterTable
ALTER TABLE "security_employee" ADD COLUMN     "email" VARCHAR(150);

-- CreateIndex
CREATE UNIQUE INDEX "security_employee_email_key" ON "security_employee"("email");
```

Поле необов'язкове (`String?`), тому міграція не ламає наявні рядки.

---

## 6. Міграція 3: `add_incident_resolved_at` (нове поле)

**Що змінено:** в `incident` додано необов'язкове поле `resolved_at` (час закриття інциденту).

**До:** модель `incident` без `resolved_at`.

**Після:**

```prisma
model incident {
  // ...
  severity    String    @db.VarChar(20)
  resolved_at DateTime? @db.Timestamp(6)
  // ...
}
```

```bash
bunx prisma migrate dev --name add-incident-resolved-at
```

**Згенерований SQL** (`20261116203346_add_incident_resolved_at`):

```sql
-- AlterTable
ALTER TABLE "incident" ADD COLUMN     "resolved_at" TIMESTAMP(6);
```

---

## 7. Міграція 4: `add_visit_student_index` (індекс)

**Що змінено:** у `visit` додано індекс на зовнішній ключ `student_id`, щоб пришвидшити вибірку візитів студента.

**До:** модель `visit` без `@@index`.

**Після:**

```prisma
model visit {
  // ...
  student  student @relation(fields: [student_id], references: [student_id], onDelete: NoAction, onUpdate: NoAction, map: "fk_visit_student")

  @@index([student_id])
}
```

```bash
bunx prisma migrate dev --name add-visit-student-index
```

**Згенерований SQL** (`20261116203418_add_visit_student_index`):

```sql
-- CreateIndex
CREATE INDEX "visit_student_id_idx" ON "visit"("student_id");
```

---

## 8. Міграція 5: `rename_visit_category_to_visit_type` (перейменування стовпця)

**Що змінено:** стовпець `visit.category` перейменовано на `visit_type`.

**До:**

```prisma
category String @default("Відпочинок") @db.VarChar(50)
```

**Після:**

```prisma
visit_type String @default("Відпочинок") @db.VarChar(50)
```

Prisma не розпізнає перейменування і трактує його як «видалити `category` + додати `visit_type`». Це призвело б до втрати даних у стовпці (про це й попереджає коментар у згенерованому файлі). Тому міграцію створено без застосування:

```bash
bunx prisma migrate dev --create-only --name rename-visit-category-to-visit-type
```

У створеному `migration.sql` пару `DROP COLUMN` + `ADD COLUMN` вручну замінено на `RENAME COLUMN`, після чого міграцію застосовано командою `bunx prisma migrate dev`.

**Фінальний SQL** (`20261116203505_rename_visit_category_to_visit_type`):

```sql
/*
  Warnings:

  - You are about to drop the column `category` on the `visit` table. All the data in the column will be lost.

*/
ALTER TABLE "visit" RENAME COLUMN "category" TO "visit_type";
```

Коментар-попередження згенерувала Prisma, а сама операція тепер зберігає дані.

---

## 9. Міграція 6: `drop_incident_description` (видалення стовпця)

**Що змінено:** з `incident` видалено поле `description`.

**До:**

```prisma
model incident {
  incident_id Int     @id @default(autoincrement())
  // ...
  description String?
  occurred_at DateTime @db.Timestamp(6)
  // ...
}
```

**Після:** поле `description` відсутнє.

```bash
bunx prisma migrate dev --name drop-incident-description
```

Prisma попередила про втрату даних у стовпці, зміну підтверджено.

**Згенерований SQL** (`<дата>_drop_incident_description`):

```sql
/*
  Warnings:

  - You are about to drop the column `description` on the `incident` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "incident" DROP COLUMN "description";
```

---

## 10. Перевірка через Prisma Client

Для перевірки написано скрипт `src/index.ts`. Він використовує Prisma Client з адаптером `@prisma/adapter-pg` (у Prisma 7 клієнт потребує адаптера). Тестові дані завантажено з `queries.sql`.

Скрипт:
1. вставляє коментар у нову таблицю `incident_comment`;
2. оновлює нове поле `email` у `security_employee`;
3. отримує інциденти разом із коментарями через `include`.

```bash
bun src/index.ts
```

**Вивід:**

```
[
  {
    "incident_id": 1,
    "visit_id": 1,
    "type_id": 1,
    "employee_id": 1,
    "status_id": 1,
    "description": null,
    "occurred_at": "2026-11-10T11:15:00.000Z",
    "severity": "Низький",
    "resolved_at": null,
    "incident_comment": [
      {
        "comment_id": 1,
        "incident_id": 1,
        "employee_id": 1,
        "text": "Перевірка після міграцій",
        "created_at": "2026-11-16T20:50:49.310Z"
      }
    ]
  },
  {
    "incident_id": 2,
    "visit_id": 2,
    "type_id": 3,
    "employee_id": 2,
    "status_id": 2,
    "description": null,
    "occurred_at": "2026-11-10T12:00:00.000Z",
    "severity": "Середній",
    "resolved_at": null,
    "incident_comment": []
  },
  {
    "incident_id": 3,
    "visit_id": 4,
    "type_id": 2,
    "employee_id": 1,
    "status_id": 3,
    "description": null,
    "occurred_at": "2026-11-12T10:20:00.000Z",
    "severity": "Високий",
    "resolved_at": "2026-11-12T14:00:00.000Z",
    "incident_comment": []
  }
]
```

Вивід підтверджує, що нова таблиця `incident_comment` працює (запис пов'язаний з інцидентом), нові поля `resolved_at` і `email` доступні, а `description` більше не повертається.

**Prisma Studio:**

```bash
bunx prisma studio
```
---

## 11. Перевірка стану міграцій

```bash
bunx prisma migrate status
```

Усі 7 міграцій (`init` та шість змін) застосовані, база синхронізована з історією.

---

## 12. Висновок

Схему бази даних з лабораторної роботи 5 розвинуто за допомогою Prisma Migrate: додано нову таблицю, два нові поля, індекс, перейменовано та видалено стовпці. Кожна зміна оформлена окремою міграцією, тому історія схеми відтворювана та зберігається в Git. Окремо розглянуто небезпечний випадок перейменування стовпця, де автоматична міграція Prisma втратила б дані, і його виправлено вручну через `RENAME COLUMN`.

Обмеження Prisma: CHECK-обмеження (`chk_incident_severity`, `chk_visit_dates`) вона не відображає в `schema.prisma`, тому в міграціях Prisma вони відсутні й за потреби додаються окремим SQL.