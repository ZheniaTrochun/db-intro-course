# Lab 4 — OLAP: Агрегація, GROUP BY, HAVING, JOIN

## 🇺🇦 Українською

Аналітичні запити в стилі **OLAP** — замість поодиноких операцій над одним рядком (Lab 3) запит обробляє багато рядків і повертає підсумкову відповідь: агрегатні функції (`COUNT`, `COUNT(DISTINCT)`, `SUM`, `MIN`, `MAX`, `AVG`) одним проходом; групування з `GROUP BY` і фільтрування груп через `HAVING` (WHERE фільтрує рядки до групування, HAVING — групи після); усі типи з'єднань — `INNER`, `LEFT`, анти-джойн, `FULL OUTER`, `CROSS`; багатотаблична агрегація з `COUNT(DISTINCT)` проти розмноження рядків подвійним JOIN та підзапитом із порівнянням із загальним середнім.

### Файли

- `queries.sql` — додаткові тестові дані + 14 запитів: 1 зведена агрегація, 2 GROUP BY, 3 HAVING, 5 JOIN, 3 багатотабличні
- `tasks.md` — завдання лабораторної
- `report_lab4.md` / `report_lab4.pdf` — звіт
- `screenshots/` — скріншоти виконання в pgAdmin

---

## 🇬🇧 English

**OLAP-style** analytical queries — instead of single-row operations (Lab 3), a query processes many rows and returns a summary: aggregate functions (`COUNT`, `COUNT(DISTINCT)`, `SUM`, `MIN`, `MAX`, `AVG`) in a single pass; grouping with `GROUP BY` and group filtering via `HAVING` (WHERE filters rows before grouping, HAVING filters groups after); all join types — `INNER`, `LEFT`, anti-join, `FULL OUTER`, `CROSS`; multi-table aggregation with `COUNT(DISTINCT)` against double-JOIN row multiplication and a subquery comparing against the platform-wide average.

### Files

- `queries.sql` — extra test data + 14 queries: 1 combined aggregation, 2 GROUP BY, 3 HAVING, 5 JOIN, 3 multi-table
- `tasks.md` — lab assignment
- `report_lab4.md` / `report_lab4.pdf` — report
- `screenshots/` — execution screenshots from pgAdmin
