# Лабораторна робота №2 — DDL

**Предмет:** Бази даних  
**Виконав:** Биченко Роман В'ячеславович, ІМ-54  
**Предметна область:** Інтернет-магазин автозапчастин.

## Мета

Перетворити ER-модель з [лабораторної №1](https://github.com/ZheniaTrochun/db-intro-course/pull/335) на реляційну схему PostgreSQL, заповнити таблиці тестовими даними та перевірити обмеження.

## Файли

| Файл | Призначення |
|---|---|
| [schema.sql](schema.sql) | DDL: створення таблиць, ключів і обмежень |
| [data.sql](data.sql) | INSERT: заповнення таблиць тестовими даними |
| [queries.sql](queries.sql) | Сім перевірочних SELECT-запитів |
| [constraint-tests.sql](constraint-tests.sql) | 20 тестів обмежень і DEFAULT |
| [REPORT.md](REPORT.md) | Опис схеми та фактичні результати |
| [screenshots/](screenshots/) | Скриншоти локального тестування |

## Порядок запуску

Потрібні PostgreSQL та клієнт psql. На моєму комп'ютері використано Windows, клієнт psql 17.12, localhost, порт 5433, користувач postgres. Docker не використовувався. Якщо у вас інший порт (наприклад, 5432), користувач або шлях до psql, змініть відповідні параметри. Пароль вводиться при запиті клієнта.

Команди виконуються в PowerShell з кореня репозиторію. Спочатку створіть нову порожню базу (якщо така вже існує, використайте іншу назву в усіх командах):

```powershell
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
& $psql -h localhost -p 5433 -U postgres -d postgres -X -v ON_ERROR_STOP=1 -c "CREATE DATABASE auto_parts_lab2;"
```

Потім виконайте по черзі:

```powershell
& $psql -h localhost -p 5433 -U postgres -d auto_parts_lab2 -X -v ON_ERROR_STOP=1 -f ".\lab2-auto-parts\schema.sql"
& $psql -h localhost -p 5433 -U postgres -d auto_parts_lab2 -X -v ON_ERROR_STOP=1 -f ".\lab2-auto-parts\data.sql"
& $psql -h localhost -p 5433 -U postgres -d auto_parts_lab2 -X -P pager=off -v ON_ERROR_STOP=1 -f ".\lab2-auto-parts\queries.sql"
& $psql -h localhost -p 5433 -U postgres -d auto_parts_lab2 -X -v ON_ERROR_STOP=1 -f ".\lab2-auto-parts\constraint-tests.sql"
```

Якщо будь-яка команда завершилася помилкою, не запускайте наступну до її виправлення. schema.sql та data.sql розраховані на одноразовий запуск у новій базі. Перевірочні запити і тести можна запускати повторно на початкових тестових даних. Тестові зміни відкочуються через ROLLBACK.

## Очікуваний результат

- 7 таблиць, 46 тестових записів сумарно.
- Суми замовлень за ID 1–5: 1900, 2750, 3700, 2800, 1400 грн.
- Успішні оплати: 8350 грн.
- Три товари із залишком менше 5 одиниць.
- Історична ціна масляного фільтра — 400 грн, поточна — 500 грн.
- Замовлень без позицій у тестових даних немає.
- Усі 20 тестів повинні вивести PASS; наприкінці — `All 20 constraint/default tests passed` та `ROLLBACK`.

## Підтвердження виконання

Локальні результати відповідають очікуваним. Скриншоти: [таблиці](screenshots/01-tables.png), [запити](screenshots/02-query-results.png), [тести](screenshots/03-constraint-tests.png).

Детальніше — у [звіті](REPORT.md).
