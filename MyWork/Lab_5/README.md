# Lab 5 — Нормалізація БД (1NF–3NF)

## 🇺🇦 Українською

Аналіз схеми на нормальні форми та практичне лікування денормалізації. Головна схема VideoHub перевірена запитами: 1NF (нуль колонок-масивів), 2NF (атрибути композитних ключів залежать від повної пари), 3NF (атрибути автора живуть у User) — чисто за дизайном. Навмисно створена «хвора» таблиця `VideoDenormalized` з трьома діагнозами (теги списком — 1NF, категорія через слеш — 1NF, атрибути автора транзитивно — 3NF), діагностика аномалій наживо (LIKE-хак по списку, дублі довідника), повне лікування: junction `Tag`/`VideoTag` для M:N, ALTER-хірургія за золотим правилом (ADD → split_part → DROP → RENAME), наповнення через CROSS JOIN з ON CONFLICT (ідемпотентність), верифікація — той самий інфо-контент через JOIN, дані не втрачені.

### Файли

- `queries.sql` — аналіз схеми + «хвора» таблиця + діагностика + лікування + верифікація
- `tasks.md` — завдання лабораторної
- `report_lab5.md` / `report_lab5.pdf` — звіт
- `screenshots/` — скріншоти виконання в pgAdmin

---

## 🇬🇧 English

Schema normalization analysis and hands-on denormalization treatment. The main VideoHub schema verified by queries: 1NF (zero array columns), 2NF (composite-key attributes depend on the full pair), 3NF (author attributes live in User) — clean by design. A deliberately "sick" table `VideoDenormalized` created with three diagnoses (comma-separated tags — 1NF, slash-joined category — 1NF, transitive author attributes — 3NF), live anomaly diagnostics (LIKE-hack over the list, lookup duplicates), full treatment: `Tag`/`VideoTag` junction for M:N, ALTER surgery by the golden rule (ADD → split_part → DROP → RENAME), population via CROSS JOIN with ON CONFLICT (idempotency), verification — the same info content via JOIN, no data lost.

### Files

- `queries.sql` — schema analysis + sick table + diagnostics + treatment + verification
- `tasks.md` — lab assignment
- `report_lab5.md` / `report_lab5.pdf` — report
- `screenshots/` — execution screenshots from pgAdmin
