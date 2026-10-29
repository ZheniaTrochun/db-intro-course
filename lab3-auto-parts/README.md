# Лабораторна робота №3 — OLTP

**Предмет:** Бази даних

**Виконав:** Биченко Роман В'ячеславович, ІМ-54

**Предметна область:** Інтернет-магазин автозапчастин.

## Мета

Навчитися отримувати, додавати, змінювати та видаляти дані в PostgreSQL, перевіряти результати операцій і використовувати транзакції.

## Файли та порядок запуску

| № | Файл | Призначення |
|---|---|---|
| 1 | [select.sql](select.sql) | 7 запитів для отримання даних |
| 2 | [insert.sql](insert.sql) | 5 операцій додавання з перевіркою та ROLLBACK |
| 3 | [update.sql](update.sql) | 5 операцій оновлення з перевіркою та ROLLBACK |
| 4 | [delete.sql](delete.sql) | 3 операції видалення з перевіркою та ROLLBACK |
| 5 | [transactions.sql](transactions.sql) | Успішне та відхилене замовлення |
| 6 | [tests.sql](tests.sql) | 18 перевірок кінцевого стану |

[REPORT.md](REPORT.md) — опис кожної основної операції та фактичних результатів. У папці `screenshots/` містяться результати локального тестування.

## Підготовка бази

Потрібен PostgreSQL та клієнт psql. Роботу перевірено в PostgreSQL на локальному сервері через порт 5433. Структуру і початкові дані взято з [лабораторної №2 (PR #339)](https://github.com/ZheniaTrochun/db-intro-course/pull/339). Для третьої роботи використовується окрема база `auto_parts_lab3`.

Якщо база ще не створена, виконайте в PowerShell з кореня репозиторію наведені команди. Вони отримають `schema.sql` і `data.sql` з гілки другої лабораторної, не додаючи їх у поточну гілку.

```powershell
$psql = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$port = 5433
$setup = Join-Path $env:TEMP ('lab3-setup-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $setup

git fetch https://github.com/RomanBychenko/db-intro-course.git lab-2
git archive --format=zip --output="$setup\lab2.zip" FETCH_HEAD lab2-auto-parts/schema.sql lab2-auto-parts/data.sql
Expand-Archive -LiteralPath "$setup\lab2.zip" -DestinationPath $setup

& $psql -h localhost -p $port -U postgres -d postgres -v ON_ERROR_STOP=1 -c 'CREATE DATABASE auto_parts_lab3;'
& $psql -h localhost -p $port -U postgres -d auto_parts_lab3 -X -v ON_ERROR_STOP=1 -f "$setup\lab2-auto-parts\schema.sql"
& $psql -h localhost -p $port -U postgres -d auto_parts_lab3 -X -v ON_ERROR_STOP=1 -f "$setup\lab2-auto-parts\data.sql"
```

Шлях до psql, порт та користувача потрібно змінити відповідно до свого середовища. Пароль вводиться у відповідь на запит psql. У разі помилки не продовжуйте запуск наступного файлу до її виправлення.

## Запуск лабораторної

Виконайте з кореня репозиторію на початкових даних (7 таблиць, 46 записів):

```powershell
$psql = 'C:\Program Files\PostgreSQL\17\bin\psql.exe'
$port = 5433
$files = 'select.sql', 'insert.sql', 'update.sql', 'delete.sql', 'transactions.sql', 'tests.sql'
foreach ($file in $files) {
    & $psql -h localhost -p $port -U postgres -d auto_parts_lab3 -X -P pager=off -v ON_ERROR_STOP=1 -f ".\lab3-auto-parts\$file"
    if ($LASTEXITCODE -ne 0) { throw "SQL error in $file" }
}
```

`insert.sql`, `update.sql` та `delete.sql` скасовують демонстраційні зміни. `transactions.sql` зберігає замовлення №9002 через COMMIT, тому його слід виконувати один раз на початкових даних. Для повного повторного запуску підготуйте нову тестову базу з тими самими початковими даними та вкажіть її назву у командах. Не видаляйте базу другої лабораторної. `tests.sql` можна повторно запускати на кінцевому стані після успішної транзакції.

У pgAdmin можна підключитися до локального сервера, відкрити базу `auto_parts_lab3` та через Query Tool переглянути замовлення №9002 або виконати `tests.sql` на кінцевому стані.

## Очікуваний кінцевий результат

- 7 таблиць, 49 записів (початково 46).
- Замовлення №9002 має статус `confirmed`, оплата 1500 грн зі статусом `successful`.
- Залишок товару №1 становить 16, товару №8 — 0.
- Замовлення №9003 не існує.
- Сума успішних оплат — 9850 грн.
- 18 із 18 перевірок — PASS.

Фактичні результати наведено у [звіті](REPORT.md) та на [скриншоті тестів](screenshots/06-tests.png).
