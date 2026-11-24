# Lab 2 — DDL: CREATE TABLE, INSERT

## 🇺🇦 Українською

Фізична реалізація схеми з Lab 1 у **PostgreSQL**: створення 5 таблиць через `CREATE TABLE` з типами даних, ключами, зовнішніми ключами та обмеженнями (`UNIQUE`, `CHECK`, `ON DELETE CASCADE`), плюс наповнення тестовими даними через `INSERT` (5 користувачів, відео, коментарі, лайки, підписки).

### Ключові рішення схеми

- **Сурогатні ключі** `UUID` (`uuid_generate_v4()`) у `User`, `Video`, `Comment` — стабільні id, на які посилаються зовні.
- **Композитні первинні ключі** у таблиць-зв'язок: `Like` → `PRIMARY KEY (user_id, video_id)`, `Subscription` → `PRIMARY KEY (subscriber_id, channel_id)`. Пара FK сама є ключем — жодної «мертвої» колонки `id` і жодного зайвого індексу.
- **CHECK-обмеження:** `User` має спосіб входу (`password` АБО `google_id`), `views >= 0` у `Video`, заборона самопідписки `subscriber_id <> channel_id`.
- Усі FK з `ON DELETE CASCADE` — посилальна цілісність без сирітських рядків.
- Порівняння до/після переходу на композитні ключі — у діаграмах `er_schema_old.mmd` / `er_schema_new.mmd`.

### Файли

- `schema.sql` — DDL-скрипт: `CREATE EXTENSION`, `CREATE TABLE`, `INSERT`
- `er_schema_old.mmd` / `er_schema_new.mmd` — діаграми схеми до/після композитних ключів (+ PNG у screenshots)
- `tasks.md` — завдання лабораторної
- `report_lab2.md` / `report_lab2.pdf` — звіт
- `screenshots/` — скріншоти виконання в pgAdmin

---

## 🇬🇧 English

Physical implementation of the Lab 1 schema in **PostgreSQL**: 5 tables created via `CREATE TABLE` with data types, keys, foreign keys and constraints (`UNIQUE`, `CHECK`, `ON DELETE CASCADE`), plus test data inserted via `INSERT` (5 users, videos, comments, likes, subscriptions).

### Key schema decisions

- **UUID surrogate keys** for `User`, `Video`, `Comment` — stable ids referenced externally.
- **Composite primary keys** on junction tables: `Like` → `PRIMARY KEY (user_id, video_id)`, `Subscription` → `PRIMARY KEY (subscriber_id, channel_id)`. No dead `id` column, no redundant index — the pair itself is the key.
- **CHECKs:** auth method required in `User` (`password` OR `google_id`), `views >= 0` in `Video`, no self-subscription.
- All FKs use `ON DELETE CASCADE`. Schema before/after comparison in `er_schema_old.mmd` / `er_schema_new.mmd`.

### Files

- `schema.sql` — DDL script: `CREATE EXTENSION`, `CREATE TABLE`, `INSERT`
- `er_schema_old.mmd` / `er_schema_new.mmd` — schema diagrams before/after composite keys
- `tasks.md` — lab assignment
- `report_lab2.md` / `report_lab2.pdf` — report
- `screenshots/` — execution screenshots from pgAdmin
