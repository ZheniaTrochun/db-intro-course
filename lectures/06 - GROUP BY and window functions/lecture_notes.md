# Лекція 6: Агрегація, групування та віконні функції

## Теми лекції

- Групування та агрегації
- Функції агрегації та `NULL`
- `GROUP BY` та `HAVING`
- Логічний порядок виконання запиту
- Віконні функції (window functions), зокрема функції ранжування

Усі приклади написано для схеми з [create-campus-tables.sql](../../scripts/create-campus-tables.sql) і даних з [insert-data.sql](../../scripts/insert-data.sql).
Наведені результати отримано саме на цих даних.

---

## 1. Функції агрегації

Функції агрегації працюють над множиною рядків і повертають одне значення.
Найпоширеніші:
- `COUNT()` - кількість
- `SUM()` - сума
- `AVG()` - середнє значення
- `MIN()` - мінімальне значення
- `MAX()` - максимальне значення

Якщо в запиті немає `GROUP BY`, уся вибірка вважається однією групою, і результат складається з одного рядка:
```sql
SELECT AVG(grade)
FROM enrolment;
```
Запит повертає середнє значення `grade` по всіх записах на курси, де оцінку вже виставлено.
Це не те саме, що "середній бал студентів": студент з пʼятьма курсами впливає на результат у пʼять разів сильніше,
ніж студент з одним курсом. На даних курсу середнє по записах становить 77.31, а середнє від середніх балів студентів 78.11.
Тому перед написанням агрегації варто чітко сформулювати, середнє чого саме потрібне.

### Агрегати та `NULL`

Усі функції агрегації, крім `COUNT(*)`, ігнорують `NULL`. Через це існують три різні форми `COUNT`:

| Вираз | Що рахує |
|---|---|
| `COUNT(*)` | кількість рядків |
| `COUNT(column)` | кількість значень, що не є `NULL` |
| `COUNT(DISTINCT column)` | кількість унікальних значень, що не є `NULL` |

```sql
SELECT
    COUNT(*)                   AS enrolments,
    COUNT(grade)               AS graded,
    COUNT(DISTINCT student_id) AS students,
    ROUND(AVG(grade), 2)       AS avg_grade
FROM enrolment;
```
```
 enrolments | graded | students | avg_grade
------------+--------+----------+-----------
        251 |    194 |       38 |     77.31
```
Із 251 запису оцінку мають 194, і `AVG` рахує середнє лише по них.

Якщо агрегувати нічого (жодного рядка або жодного значення, що не є `NULL`), `COUNT` повертає `0`, а `SUM`, `AVG`, `MIN`, `MAX` повертають `NULL`.
Наприклад, на курсі 7 є 6 записів, але жодної оцінки:
```sql
SELECT COUNT(*), COUNT(grade), SUM(grade), AVG(grade)
FROM enrolment
WHERE course_id = 7;
```
```
 count | count | sum | avg
-------+-------+-----+-----
     6 |     0 |     |
```
Щоб отримати `0` замість `NULL`, використовують `COALESCE(SUM(grade), 0)`.
Для `AVG` така заміна зазвичай некоректна: "оцінок немає" і "середній бал 0" означають різне.

---

## 2. Групування даних: `GROUP BY`

Часто потрібне не одне загальне значення, а окреме значення для кожної групи (кожного курсу, студента, групи).
Для цього використовується `GROUP BY`: він обʼєднує рядки з однаковими значеннями вказаних колонок в одну групу,
і функції агрегації обчислюються окремо для кожної групи.

Синтаксис:
```sql
SELECT group_column, AGGREGATE_FUNCTION(column_name)
FROM table_name
GROUP BY group_column;
```

### Приклад

| student_id | course_id | grade |
|---|---|---|
| 1 | 1 | 80 |
| 2 | 1 | 90 |
| 3 | 2 | 95 |
| 3 | 1 | 85 |

```sql
SELECT course_id, AVG(grade)
FROM enrolment
GROUP BY course_id;
```
Рядки з `course_id = 1` утворюють одну групу (80, 90, 85 -> середнє 85), рядок з `course_id = 2` іншу (95 -> 95).
Результат містить один рядок на кожну групу:

| course_id | avg |
|---|---|
| 1 | 85 |
| 2 | 95 |

### Групування за кількома колонками

Група визначається комбінацією значень усіх колонок з `GROUP BY`:
```sql
SELECT course_id, enrolment_status, COUNT(*) AS enrolments
FROM enrolment
WHERE course_id IN (5, 8)
GROUP BY course_id, enrolment_status
ORDER BY course_id, enrolment_status;
```
```
 course_id | enrolment_status | enrolments
-----------+------------------+------------
         5 | started          |          7
         5 | finished         |         21
         8 | not_started      |          7
         8 | started          |         15
         8 | finished         |          9
```

### Групування за виразом

Групувати можна не лише за колонкою, а й за виразом, наприклад за роком з дати:
```sql
SELECT EXTRACT(YEAR FROM created_at) AS enrolment_year, COUNT(*) AS enrolments
FROM enrolment
GROUP BY EXTRACT(YEAR FROM created_at)
ORDER BY enrolment_year;
```

### `GROUP BY` разом з `JOIN`

На практиці групування майже завжди поєднується з `JOIN`: спочатку таблиці зʼєднуються, потім результат групується.
```sql
SELECT 
    c.course_id, 
    c.course_name,
    COUNT(*)               AS enrolments,
    COUNT(e.grade)         AS graded,
    ROUND(AVG(e.grade), 2) AS avg_grade
FROM enrolment e
    INNER JOIN course c ON c.course_id = e.course_id
GROUP BY c.course_id
ORDER BY avg_grade DESC NULLS LAST;
```
Чому тут можна вибрати `c.course_name`, хоча в `GROUP BY` є лише `c.course_id`, пояснено в наступному розділі.
Про `NULLS LAST` йдеться в розділі 9.

---

## 3. Що можна вказувати в `SELECT` при `GROUP BY`

Після групування кожна група перетворюється на один рядок. Тому кожен вираз у `SELECT`, `HAVING` і `ORDER BY` має бути однозначним для групи, тобто бути:
- колонкою з `GROUP BY` або виразом над такими колонками (наприклад, `p.first_name || ' ' || p.last_name`, якщо обидві колонки є в `GROUP BY`)
- функцією агрегації
- будь-якою колонкою таблиці, первинний ключ якої є в `GROUP BY`

Останній пункт називається функціональною залежністю: якщо відомий `course_id`, то `course_name` і `credits` однозначно визначені,
тому PostgreSQL дозволяє їх вибирати. Якщо ж групувати за неключовою колонкою, це правило не діє:
```sql
SELECT c.course_name, c.credits, COUNT(e.student_id)
FROM course c
    LEFT JOIN enrolment e ON e.course_id = c.course_id
GROUP BY c.course_name;
-- ERROR:  column "c.credits" must appear in the GROUP BY clause or be used in an aggregate function
```

Так само не вийде вивести окрему оцінку поруч із середнім по групі:
```sql
SELECT course_id, grade, AVG(grade)
FROM enrolment
GROUP BY course_id;
-- ERROR:  column "enrolment.grade" must appear in the GROUP BY clause or be used in an aggregate function
```
У групі курсу багато оцінок, і СУБД не знає, яку з них показати. Цю задачу розвʼязують віконні функції (розділ 7).

> Деякі СУБД (наприклад, MySQL у старих версіях) у такій ситуації повертають довільне значення з групи.
> Це джерело непомітних помилок, тому стандарт SQL і PostgreSQL такий запит забороняють.

---

## 4. `JOIN` перед агрегацією розмножує рядки

`JOIN` повертає по рядку на кожну пару відповідних рядків. Якщо до курсу приєднати і записи студентів, і викладачів,
кожен запис студента повториться стільки разів, скільки на курсі викладачів:
```sql
SELECT c.course_name,
       COUNT(e.student_id)    AS students,
       COUNT(ct.professor_id) AS professors
FROM course c
    JOIN enrolment e       ON e.course_id = c.course_id
    JOIN course_teacher ct ON ct.course_id = c.course_id
WHERE c.course_id IN (1, 2)
GROUP BY c.course_id;
```
```
     course_name     | students | professors
---------------------+----------+------------
 Програмування       |       70 |         70
 Математичний аналіз |       35 |         35
```
На курсі "Програмування" 35 студентів і 2 викладачі, тож запит порахував 35 × 2 = 70 пар.
Для курсу з одним викладачем результат випадково правильний, і саме тому таку помилку легко пропустити.

Для кількостей допомагає `COUNT(DISTINCT ...)`:
```sql
SELECT c.course_name,
       COUNT(DISTINCT e.student_id)    AS students,
       COUNT(DISTINCT ct.professor_id) AS professors
FROM course c
    JOIN enrolment e       ON e.course_id = c.course_id
    JOIN course_teacher ct ON ct.course_id = c.course_id
WHERE c.course_id IN (1, 2)
GROUP BY c.course_id;
```
```
     course_name     | students | professors
---------------------+----------+------------
 Програмування       |       35 |          2
 Математичний аналіз |       35 |          1
```
Для `SUM` і `AVG` `DISTINCT` не підходить: `SUM(DISTINCT credits)` злиє в одне значення два різні курси з однаковою кількістю кредитів.
У таких випадках варто надавати перевагу агрегації кожної таблиці окремо (через підзапит, про це в лекції 7)
або зʼєднанню лише з тими таблицями, які дійсно потрібні для результату.

---

## 5. Фільтрація: `WHERE` та `HAVING`

`WHERE` фільтрує окремі рядки ДО групування. `HAVING` фільтрує групи ПІСЛЯ групування і може використовувати функції агрегації.

Курси, де середній бал вищий за 80:
```sql
SELECT course_id, ROUND(AVG(grade), 2) AS avg_grade
FROM enrolment
GROUP BY course_id
HAVING AVG(grade) > 80;
```
```
 course_id | avg_grade
-----------+-----------
         6 |     81.38
         8 |     80.78
        12 |     86.00
```

Обидві умови можна поєднувати. Середній бал по завершених записах лише для курсів, де таких записів щонайменше 20:
```sql
SELECT course_id, ROUND(AVG(grade), 2) AS avg_grade
FROM enrolment
WHERE enrolment_status = 'finished'
GROUP BY course_id
HAVING COUNT(*) >= 20
ORDER BY avg_grade DESC;
```

Умову на окремі рядки варто розміщувати у `WHERE`, а не в `HAVING`. Так рядки відкидаються раніше, і запит легше читати.

### Умовна агрегація: `FILTER`

Якщо в одному запиті потрібно кілька агрегатів з різними умовами, зручно використовувати `FILTER`:
```sql
SELECT course_id,
       COUNT(*)                                AS enrolments,
       COUNT(*) FILTER (WHERE grade >= 90)     AS excellent,
       COUNT(*) FILTER (WHERE grade < 60)      AS failed
FROM enrolment
WHERE course_id IN (1, 2, 3)
GROUP BY course_id;
```
```
 course_id | enrolments | excellent | failed
-----------+------------+-----------+--------
         1 |         35 |        11 |      2
         2 |         35 |        11 |      5
         3 |         35 |         9 |      4
```


### `LEFT JOIN` і умова у `WHERE`

Задача: для кожного викладача порахувати кількість активних курсів і суму їхніх кредитів, включно з викладачами без курсів.
Інтуїтивний варіант:
```sql
SELECT p.first_name || ' ' || p.last_name AS full_name,
       COUNT(c.course_id)                 AS course_count,
       COALESCE(SUM(c.credits), 0)        AS sum_of_credits
FROM professor prof
    JOIN person p              ON p.person_id = prof.person_id
    LEFT JOIN course_teacher ct ON ct.professor_id = prof.professor_id
    LEFT JOIN course c          ON c.course_id = ct.course_id
WHERE c.course_status = 'active' OR c.course_status IS NULL
GROUP BY prof.professor_id, p.first_name, p.last_name;
```
Запит повертає 10 рядків з 11 викладачів. Сергій Тимошенко викладає лише курс зі статусом `in development`.
Його рядок має `course_status = 'in development'`, `WHERE` його відкидає, і викладач зникає з результату замість рядка "0 курсів".
Умова `IS NULL` рятує лише викладачів, у яких курсів немає зовсім.

Умову на праву таблицю `LEFT JOIN` варто розміщувати в `ON`. Тоді неактивні курси просто не приєднуються, а сам викладач лишається:
```sql
SELECT p.first_name || ' ' || p.last_name AS full_name,
       COUNT(c.course_id)                 AS course_count,
       COALESCE(SUM(c.credits), 0)        AS sum_of_credits
FROM professor prof
    JOIN person p              ON p.person_id = prof.person_id
    LEFT JOIN course_teacher ct ON ct.professor_id = prof.professor_id
    LEFT JOIN course c          ON c.course_id = ct.course_id AND c.course_status = 'active'
GROUP BY prof.professor_id, p.first_name, p.last_name;
```
Тепер результат містить усіх 11 викладачів, Тимошенко з `0` курсів і `0` кредитів.
Тут використано `COUNT(c.course_id)`, а не `COUNT(*)`, бо для викладача без курсів `LEFT JOIN` дає один рядок з `NULL`, і `COUNT(*)` порахував би його як 1.

---

## 6. Логічний порядок виконання запиту

Запит записується в порядку `SELECT ... FROM ... WHERE ...`, але логічно обчислюється в іншому порядку:

1. `FROM` / `JOIN` - формування вихідного набору рядків
2. `WHERE` - фільтрація окремих рядків
3. `GROUP BY` - групування
4. `HAVING` - фільтрація груп
5. віконні функції
6. `SELECT` - обчислення виразів і присвоєння псевдонімів (alias)
7. `DISTINCT` - видалення дублікатів
8. `ORDER BY` - сортування
9. `LIMIT` / `OFFSET` - обмеження кількості рядків

Наслідки цього порядку:
- функції агрегації не можна використовувати у `WHERE`, бо на цьому кроці групи ще не сформовано
- псевдонім із `SELECT` не видно у `WHERE` і `HAVING`, але видно в `ORDER BY`:
  ```sql
  SELECT course_id, AVG(grade) AS avg_grade
  FROM enrolment
  GROUP BY course_id
  HAVING avg_grade > 80;
  -- ERROR:  column "avg_grade" does not exist
  ```
  Тому в `HAVING` повторюють вираз (`HAVING AVG(grade) > 80`), а в `ORDER BY avg_grade` псевдонім працює.
- віконні функції обчислюються після `GROUP BY` і `HAVING`, тому вони бачать уже згруповані рядки, але їх не можна використовувати у `WHERE` чи `HAVING` (розділи 10 і 11)

Це логічний порядок, тобто опис того, яким має бути результат. Фактичний план виконання може відрізнятися.

---

## 7. Віконні функції

У розділі 3 запит "оцінка студента поруч із середнім балом курсу" завершився помилкою: `GROUP BY` згортає групу в один рядок, і окремі оцінки зникають.
Віконні функції (window functions) обчислюють агрегат по групі рядків, але не згортають рядки: кожен рядок лишається в результаті й отримує додаткове значення.

Синтаксис:
```sql
FUNCTION(column_name) OVER (window_definition)
```
`OVER (...)` визначає **вікно**, тобто набір рядків, по якому обчислюється функція для поточного рядка.

### `OVER()`: одне вікно на весь запит

Порожні дужки означають, що вікно складається з усіх рядків результату:
```sql
SELECT e.student_id, e.grade,
       ROUND(AVG(e.grade) OVER (), 2) AS avg_grade,
       COUNT(*) OVER ()               AS total_rows
FROM enrolment e
WHERE e.course_id = 12;
```
```
 student_id | grade | avg_grade | total_rows
------------+-------+-----------+------------
         31 |   100 |     86.00 |          6
         33 |    91 |     86.00 |          6
         ...
```
Вікно бачить не всю таблицю, а лише рядки, що залишилися після `FROM`, `WHERE`, `GROUP BY` і `HAVING`.
Тут `WHERE` залишив 6 рядків курсу 12, тож `AVG` і `COUNT` обчислено по цих 6 рядках.

### `PARTITION BY`: окреме вікно для кожної групи

`PARTITION BY` ділить рядки на партиції (подібно до `GROUP BY`), і функція обчислюється в межах партиції поточного рядка:
```sql
SELECT e.student_id, c.course_name, e.grade,
       ROUND(AVG(e.grade) OVER (PARTITION BY e.course_id), 2)           AS avg_course_grade,
       e.grade - ROUND(AVG(e.grade) OVER (PARTITION BY e.course_id), 2) AS diff
FROM enrolment e
    JOIN course c ON c.course_id = e.course_id
WHERE e.course_id IN (11, 12)
ORDER BY c.course_name, e.grade DESC;
```
```
 student_id |    course_name    | grade | avg_course_grade |  diff
------------+-------------------+-------+------------------+--------
         33 | Кібербезпека      |    92 |            79.83 |  12.17
         ...
         34 | Кібербезпека      |    49 |            79.83 | -30.83
         31 | Хмарні технології |   100 |            86.00 |  14.00
         ...
```
Кожен рядок містить оцінку студента і середній бал його курсу, однаковий для всіх рядків курсу.

### Кілька вікон в одному запиті

В одному запиті можна використати кілька віконних функцій з різними партиціями:
```sql
SELECT e.student_id, e.course_id, e.grade,
       ROUND(AVG(e.grade) OVER (PARTITION BY e.course_id), 2)  AS avg_course_grade,
       ROUND(AVG(e.grade) OVER (PARTITION BY e.student_id), 2) AS avg_student_grade
FROM enrolment e
ORDER BY e.student_id, e.course_id;
```
Якщо до цього запиту додати `WHERE e.student_id = 1`, `avg_course_grade` стане рівним оцінці самого студента:
`WHERE` виконується раніше, і в партиції кожного курсу залишиться один рядок.
Тобто якщо потрібне порівняння з показником по всій таблиці, рядки варто фільтрувати вже після обчислення вікна (розділ 11).

---

## 8. `ORDER BY` у вікні та рамка (frame)

`ORDER BY` всередині `OVER (...)` задає порядок рядків у партиції. Він потрібен функціям ранжування (розділ 9),
функціям `LAG` / `LEAD` (значення з попереднього чи наступного рядка) і накопичувальним обчисленням.

Для функцій агрегації `ORDER BY` змінює результат. Агрегат обчислюється не по всій партиції, а по рамці (frame).
Якщо `ORDER BY` є, рамка за замовчуванням охоплює рядки від першого в партиції до поточного (разом з рядками, рівними поточному).
Агрегат стає накопичувальним:
```sql
SELECT e.student_id, e.grade,
       ROUND(AVG(e.grade) OVER (), 2)                 AS avg_all,
       ROUND(AVG(e.grade) OVER (ORDER BY e.grade), 2) AS avg_running
FROM enrolment e
WHERE e.course_id = 12
ORDER BY e.grade;
```
```
 student_id | grade | avg_all | avg_running
------------+-------+---------+-------------
         35 |    71 |   86.00 |       71.00
         34 |    77 |   86.00 |       74.00
         32 |    86 |   86.00 |       78.00
         33 |    91 |   86.00 |       83.20
         36 |    91 |   86.00 |       83.20
         31 |   100 |   86.00 |       86.00
```
`avg_running` у кожному рядку дорівнює середньому від найменшої оцінки до поточної.
Обидва рядки з оцінкою 91 мають однакове значення, бо рядки з рівним значенням сортування потрапляють у рамку разом.

Тому якщо потрібне просто середнє по групі, варто надавати перевагу `OVER (PARTITION BY ...)` без `ORDER BY`.

Рамку можна задати явно:
- `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` - від першого рядка до поточного, рівні значення не обʼєднуються
- `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` - поточний і два попередні рядки (ковзне середнє за три значення)

Різниця між рамкою за замовчуванням (`RANGE`) і `ROWS` помітна при однакових значеннях:
```sql
SELECT name, grade,
       SUM(grade) OVER (ORDER BY grade) AS sum_range,
       SUM(grade) OVER (ORDER BY grade ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_rows
FROM (VALUES ('A', 95), ('B', 90), ('C', 90), ('D', 85)) AS t(name, grade)
ORDER BY grade, name;
```
```
 name | grade | sum_range | sum_rows
------+-------+-----------+----------
 D    |    85 |        85 |       85
 B    |    90 |       265 |      175
 C    |    90 |       265 |      265
 A    |    95 |       360 |      360
```

`ORDER BY` у вікні не сортує результат запиту. Він впливає лише на обчислення функції.
Порядок рядків у результаті визначає тільки звичайний `ORDER BY` в кінці запиту.

---

## 9. Функції ранжування

- `ROW_NUMBER()` - послідовний номер рядка в партиції (1, 2, 3, ...), без повторів
- `RANK()` - ранг, однакові значення отримують однаковий ранг, після них у нумерації є пропуск
- `DENSE_RANK()` - ранг, однакові значення отримують однаковий ранг, без пропусків

Різницю видно на однакових оцінках:
```sql
SELECT name, grade,
       ROW_NUMBER() OVER w AS row_number,
       RANK()       OVER w AS rank,
       DENSE_RANK() OVER w AS dense_rank
FROM (VALUES ('A', 95), ('B', 90), ('C', 90), ('D', 85)) AS t(name, grade)
WINDOW w AS (ORDER BY grade DESC)
ORDER BY grade DESC, name;
```
```
 name | grade | row_number | rank | dense_rank
------+-------+------------+------+------------
 A    |    95 |          1 |    1 |          1
 B    |    90 |          2 |    2 |          2
 C    |    90 |          3 |    2 |          2
 D    |    85 |          4 |    4 |          3
```
`WINDOW w AS (...)` дозволяє описати вікно один раз і використати його в кількох функціях.

Кілька важливих деталей:
- Без `ORDER BY` у вікні функції ранжування не мають сенсу: `RANK() OVER ()` поверне `1` для всіх рядків.
- `ROW_NUMBER()` при однакових значеннях сортування нумерує рядки в довільному порядку, і він може змінюватися між запусками.
  Для стабільного результату варто додавати до сортування унікальну колонку: `ORDER BY grade DESC, student_id`.
- У PostgreSQL `NULL` під час сортування вважається більшим за будь-яке значення. При `ASC` він опиняється в кінці, а при `DESC` на початку.
  Тому `RANK() OVER (ORDER BY grade DESC)` поставить записи без оцінки на перше місце.
  На курсі 8 оцінку мають лише 9 записів з 31, і 22 студенти без оцінки отримали б ранг 1.
  Порядок `NULL` задається явно через `NULLS FIRST` / `NULLS LAST`.

Рейтинг студентів у межах кожного курсу:
```sql
SELECT p.first_name || ' ' || p.last_name AS full_name,
       c.course_name,
       e.grade,
       DENSE_RANK() OVER (PARTITION BY e.course_id ORDER BY e.grade DESC NULLS LAST) AS rank_in_course
FROM enrolment e
    JOIN student s ON s.student_id = e.student_id
    JOIN person p  ON p.person_id = s.person_id
    JOIN course c  ON c.course_id = e.course_id
WHERE e.course_id IN (11, 12)
ORDER BY c.course_name, rank_in_course;
```
```
     full_name      |    course_name    | grade | rank_in_course
--------------------+-------------------+-------+----------------
 Денис Онищенко     | Кібербезпека      |    92 |              1
 ...
 Владислав Карпенко | Хмарні технології |   100 |              1
 Денис Онищенко     | Хмарні технології |    91 |              2
 Наталя Сидоренко   | Хмарні технології |    91 |              2
 Христина Мазур     | Хмарні технології |    86 |              3
 ...
```

---

## 10. `GROUP BY` і віконна функція в одному запиті

Оскільки віконні функції обчислюються після `GROUP BY` (розділ 6), вони працюють уже зі згрупованими рядками.
Тому всередині `OVER (...)` можна використовувати функції агрегації.

Рейтинг студентів за середнім балом у межах групи:
```sql
SELECT sg.group_name,
       p.first_name || ' ' || p.last_name AS full_name,
       ROUND(AVG(e.grade), 2)             AS student_avg_grade,
       RANK() OVER (PARTITION BY sg.group_id ORDER BY AVG(e.grade) DESC NULLS LAST) AS student_rank
FROM student s
    JOIN student_group_assignment sga ON sga.student_id = s.student_id AND sga.assignment_status = 'active'
    JOIN student_group sg             ON sg.group_id = sga.group_id
    JOIN person p                     ON p.person_id = s.person_id
    LEFT JOIN enrolment e             ON e.student_id = s.student_id
GROUP BY sg.group_id, sg.group_name, s.student_id, p.first_name, p.last_name
ORDER BY sg.group_name, student_rank;
```
Порядок обчислення:
1. `GROUP BY` згортає записи `enrolment` до одного рядка на студента і обчислює `AVG(e.grade)`
2. віконна функція ділить ці рядки на партиції за групою і ранжує студентів за середнім балом
3. `ORDER BY` сортує результат

Партицію задано за `sg.group_id`, а не за `sg.group_name`: назва групи не має обмеження `UNIQUE`, і дві групи з однаковою назвою злилися б в один рейтинг.
Студент без жодної оцінки отримає `NULL` у `student_avg_grade` і останнє місце завдяки `NULLS LAST`.
Заміна `NULL` на `0` через `COALESCE` тут некоректна: студент без оцінок і студент із середнім балом 0 знаходяться в різних ситуаціях.

---

## 11. Фільтрація за результатом віконної функції

Віконні функції обчислюються після `WHERE` і `HAVING`, тому використати їх в умові неможливо:
```sql
SELECT e.course_id, e.student_id, e.grade
FROM enrolment e
WHERE RANK() OVER (PARTITION BY e.course_id ORDER BY e.grade DESC) = 1;
-- ERROR:  window functions are not allowed in WHERE
```
Псевдонім теж не допоможе, бо `WHERE` виконується раніше за `SELECT`.
Рішення полягає в тому, щоб обчислити вікно у підзапиті, а відфільтрувати в зовнішньому запиті. Найкращі студенти на кожному курсі:
```sql
SELECT ranked.course_name, ranked.full_name, ranked.grade
FROM (
    SELECT c.course_name,
           p.first_name || ' ' || p.last_name AS full_name,
           e.grade,
           RANK() OVER (PARTITION BY e.course_id ORDER BY e.grade DESC NULLS LAST) AS rnk
    FROM enrolment e
        JOIN student s ON s.student_id = e.student_id
        JOIN person p  ON p.person_id = s.person_id
        JOIN course c  ON c.course_id = e.course_id
    WHERE e.grade IS NOT NULL
) AS ranked
WHERE ranked.rnk = 1
ORDER BY ranked.course_name, ranked.full_name;
```
`RANK()` тут обрано свідомо: якщо кілька студентів мають однаковий найвищий бал, у результат потраплять усі (на "Дискретній математиці" їх троє з оцінкою 99).
З `ROW_NUMBER()` залишився б лише один, обраний довільно.

Детальніше підзапити розглядаються в наступній лекції.

---

## 12. Порівняння `GROUP BY` і віконних функцій

| Ознака                                  | `GROUP BY`                                           | Віконна функція (`OVER`)                                                                    |
|-----------------------------------------|------------------------------------------------------|---------------------------------------------------------------------------------------------|
| Результат                               | один рядок на групу                                  | усі рядки, до кожного додано обчислене значення                                             |
| Призначення                             | звести групу до підсумкового рядка                   | додати до кожного рядка значення, обчислене по його групі (середнє, ранг, попередній рядок) |
| Доступ до окремих рядків групи          | немає, група згорнута                                | є, з порядком через `ORDER BY` у вікні                                                      |
| Фільтрація за результатом               | `HAVING`                                             | лише через підзапит або CTE                                                                 |
| Кілька різних групувань в одному запиті | ні                                                   | так, кожна функція має власне вікно                                                         |
| Поєднання                               | можна: вікно обчислюється над результатом `GROUP BY` |                                                                                             |

---

## 13. Висновки

- Функції агрегації, крім `COUNT(*)`, ігнорують `NULL`. Важливо розрізняти `COUNT(*)`, `COUNT(column)` і `COUNT(DISTINCT column)`.
- `GROUP BY` згортає рядки з однаковими значеннями в один. У `SELECT` можуть бути лише вирази, однозначні для групи.
- `JOIN` перед агрегацією може розмножити рядки й непомітно спотворити `COUNT` і `SUM`.
- `WHERE` фільтрує рядки до групування, `HAVING` фільтрує групи після. Умову на праву таблицю `LEFT JOIN` варто розміщувати в `ON`.
- Логічний порядок виконання пояснює, де можна використовувати агрегати, віконні функції та псевдоніми.
- Віконні функції поєднують окремі рядки й агреговані значення в одному запиті. `PARTITION BY` задає партиції.
- `ORDER BY` у вікні визначає порядок для ранжування і робить агрегати накопичувальними.
- При ранжуванні варто явно вказувати, де мають бути `NULL` (`NULLS LAST`).
- Відфільтрувати рядки за результатом віконної функції можна лише через підзапит.

---

## 14. Практична частина лекції

Для демонстрації запитів під час лекції було підготовлено синтетичні дані, скрипт для їх завантаження знаходиться у [файлі](../../scripts/insert-data.sql).

Під час лекції було розроблено наступні запити:

```sql
-- порахувати розміри груп (включно з порожніми)

  
-- порахувати навантаження викладачів - скільки активних курсів та кредитів викладає кожен з викладачів

  
-- знайти усіх студентів, середній бал яких більше 90

  
-- отримати оцінки студентів у порівнянні з середнім балом по предмету
-- та з середнім балом самого студента

  
-- побудувати список за успішністю по групах
```

Всі запити також можна знайти у [файлі](../../scripts/aggregations.sql).

---

## Вправи на додаткові бали

У [директорії](../../exercises) знаходяться вправи, які можна виконати для отримання додаткових балів.
Виконані вправи потрібно оформити у вигляді `pull request` до даного репозиторію.
