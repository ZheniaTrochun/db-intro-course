# Lab 3 — OLTP: SELECT, INSERT, UPDATE, DELETE

## 🇺🇦 Українською

CRUD-операції в стилі **OLTP** — повсякденна робота додатка з даними: вибірки з `WHERE`, `LIKE`, `ORDER BY`, `LIMIT`; вставки з підзапитами для зовнішніх ключів; атомарний інкремент лічильника переглядів; видалення з демонстрацією каскадного видалення (`ON DELETE CASCADE`) по всьому графу залежних записів.

### Файли

- `queries.sql` — 11 запитів: 4 SELECT, 3 INSERT, 2 UPDATE, 2 DELETE + перевірки до/після
- `test.sql` — окрема перевірка `ON DELETE CASCADE` на тимчасових даних
- `tasks.md` — завдання лабораторної
- `report_lab3.md` / `report_lab3.pdf` — звіт
- `screenshots/` — скріншоти виконання в pgAdmin

---

## 🇬🇧 English

**OLTP-style** CRUD operations — everyday application data work: queries with `WHERE`, `LIKE`, `ORDER BY`, `LIMIT`; inserts using subqueries to resolve foreign keys; an atomic view-counter increment; deletions demonstrating `ON DELETE CASCADE` across the whole dependency graph.

### Files

- `queries.sql` — 11 queries: 4 SELECT, 3 INSERT, 2 UPDATE, 2 DELETE + before/after verifications
- `test.sql` — separate `ON DELETE CASCADE` check on temporary data
- `tasks.md` — lab assignment
- `report_lab3.md` / `report_lab3.pdf` — report
- `screenshots/` — execution screenshots from pgAdmin
