# Лекція 4: SQL частина 1 - CRUD операції

## Теми лекції

- SQL як мова та як стандарт
- CRUD-операції: INSERT, SELECT, UPDATE, DELETE
- Фільтрація, сортування, агрегація
- NULL і тризначна логіка на практиці
- Безпечні практики роботи з даними

---

## 1. SQL: мова і стандарт
- SQL (Structured Query Language) - це декларативна мова запитів: ви описуєте, *який* результат
  потрібен, а не *як* його отримати. План виконання будує сама СУБД (детальніше - лекції 11-12).
- SQL описаний стандартом ISO/IEC 9075, але "чистого SQL" на практиці не буває: кожна СУБД
  реалізує свій діалект - підмножину стандарту плюс власні розширення.
- Тому запит, який успішно виконується в PostgreSQL, може не працювати в MySQL.
- Стандарт розвивається: орієнтиром довго був SQL-92, але актуальні редакції - SQL:2016 та
  SQL:2023. PostgreSQL підтримує більшу частину обов'язкового ядра (Core SQL:2023) плюс багато
  опційних частин.

### Основні частини стандарту SQL
1. Data Definition Language (DDL) - визначення схем бази даних (створення, зміна, видалення таблиць).
2. Data Manipulation Language (DML) - робота з даними:
    - `SELECT`
    - `INSERT`
    - `UPDATE`
    - `DELETE`
3. Data Control Language (DCL) - контроль доступу (адміністрування прав).
4. Transaction Control Language (TCL) - робота з транзакціями.

### CRUD-операції
CRUD - це набір базових операцій із даними:
- Create -> `INSERT`
- Read -> `SELECT`
- Update -> `UPDATE`
- Delete -> `DELETE`

Ці чотири операції покривають усі основні потреби при роботі з даними.

---

## 2. INSERT

```sql
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);
```

### Основні особливості INSERT:
- Якщо список колонок не вказаний - значення вставляються у всі колонки таблиці в порядку їх визначення.
  Такий `INSERT` ламається при **будь-якій** зміні схеми (додали колонку в середину - і всі значення
  "з'їхали"), тому в коді список колонок пишуть завжди.
- Значень може бути **менше**, ніж колонок у таблиці: пропущені колонки отримають своє `DEFAULT`,
  а якщо `DEFAULT` не заданий - `NULL`. Якщо колонка при цьому `NOT NULL`, вставка впаде з помилкою.
- Можна вставляти кілька рядків одразу:
  ```sql
  INSERT INTO person (first_name, last_name, birth_date, phone_number, email)
  VALUES
    ('Андрій', 'Ковальчук', '2002-06-10', '380671134567', 'andriy.kovalchuk@email.com'),
    ('Марія', 'Коваленко', '2002-03-21', '380671134568', 'maria.kovalenko@email.com'),
    ('Олександр', 'Шевченко', '2001-11-02', '380671134569', 'oleksandr.shevchenko@email.com');
  ```
- Колонки з DEFAULT значеннями можна пропустити.
- Колонки з автоінкрементом (`SERIAL`, `IDENTITY`) **краще не вказувати ніколи**: явно вставлене
  значення не рухає послідовність, і через кілька таких вставок наступний автоматичний `id`
  співпаде з уже існуючим - отримаєте `duplicate key value violates unique constraint`.

### RETURNING - отримати згенеровані значення одразу

Після `INSERT` часто потрібен щойно згенерований `id`. Замість "вставив -> подивився очима ->
вписав константу" PostgreSQL повертає його одразу:
```sql
INSERT INTO person (first_name, last_name, birth_date, phone_number, email)
VALUES ('Олена', 'Гриценко', '1988-04-12', '380631234501', 'o.hrytsenko@lll.kpi.ua')
RETURNING person_id;
```
`RETURNING` працює і з `UPDATE`, і з `DELETE` - зручно, щоб побачити, що саме змінилось:
```sql
UPDATE course SET status = 'неактивний'
WHERE name = 'Комп''ютерні мережі'
RETURNING course_id, name, status;

DELETE FROM enrolment WHERE course_id = 12 RETURNING *;
```
> `RETURNING` - розширення PostgreSQL (є ще в MariaDB та SQLite), у MySQL його немає взагалі.

### INSERT ... SELECT - вставити результат запиту

Замість літералів джерелом значень може бути `SELECT`. Це основний спосіб масової вставки без
хардкоду id:
```sql
-- записати всіх студентів групи ІТ-12, які зараз навчаються, на курс "Бази даних"
INSERT INTO enrolment (student_id, course_id, start_year, status)
SELECT s.student_id, c.course_id, 2026, 'новий запис'
FROM student s
CROSS JOIN course c
WHERE c.name = 'Бази даних'
  AND s.status = 'навчається'
  AND s.group_id = (SELECT group_id FROM student_group WHERE name = 'ІТ-12');
```

### ON CONFLICT - що робити, якщо рядок уже існує

Без `ON CONFLICT` повторний запуск демонстрації падає з
`duplicate key value violates unique constraint`:
```sql
INSERT INTO enrolment (student_id, course_id, start_year, status)
VALUES (3, 8, 2026, 'новий запис')
ON CONFLICT (student_id, course_id) DO NOTHING;          -- просто проігнорувати

INSERT INTO enrolment (student_id, course_id, start_year, status)
VALUES (3, 8, 2026, 'активний')
ON CONFLICT (student_id, course_id)
DO UPDATE SET status = excluded.status;                   -- оновити наявний рядок (upsert)
```
`excluded` - це той рядок, який намагались вставити. Конструкція специфічна для PostgreSQL
(у MySQL - `ON DUPLICATE KEY UPDATE`, у стандарті - `MERGE`, який PostgreSQL підтримує з версії 15).

---

## 3. SELECT
```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Основні елементи SELECT:
- `*` - вибір усіх колонок. Не рекомендується для production-коду: результат змінюється при зміні
  схеми, по мережі їдуть непотрібні дані, і план запиту вже не може обмежитись лише індексом
  (Index Only Scan - лекції 11-12).
- `AS` - використання псевдонімів для колонок і таблиць:
  ```sql
  SELECT
    concat_ws(' ', first_name, last_name) AS full_name
  FROM person
  WHERE last_name = 'Ковальчук';
  ```
- Використовуються функції для обробки даних:
  - Рядкові: `CONCAT`, `UPPER`, `LOWER`, `SUBSTRING`
  - Числові: `ROUND`, `ABS`, `CEIL`, `FLOOR`
  - Дати/часу: `NOW()`, `DATE_PART`, `EXTRACT`
- `DISTINCT` - усунення дублікатів:
  ```sql
  SELECT DISTINCT group_id FROM student;
  ```

### Фільтрація (WHERE):
- Оператори порівняння: `=, >, <, >=, <=, <>`
  - `<>` - стандартний оператор "не рівно", `!=` - синтаксичний цукор у PostgreSQL.
- Діапазони: `BETWEEN value1 AND value2`
- Списки: `IN (value1, value2, ...)`
- Шаблони: `LIKE 'pattern'`
  - Шаблони:
      - `%` - будь-яка кількість символів.
      - `_` - рівно один символ.
  - `%` і `_` мають значення лише для `LIKE`/`ILIKE`/`SIMILAR TO`. Оператор `=` порівнює рядок
    цілком, тому `WHERE name = 'ІТ-1%'` не падає з помилкою, а просто повертає 0 рядків
  - Рядкові порівняння - чутливі до регістру.
  - Для нечутливого пошуку використовуються функції (`LOWER`, `UPPER`) або специфічні оператори
    (наприклад, `ILIKE` у PostgreSQL).
  - Важливо: `WHERE lower(name) = 'іт-12'` не може скористатись звичайним індексом по `name`, деталі - лекції 11-12.
- Логічні оператори: `AND`, `OR`, `NOT`
- Перевірка NULL: `IS NULL`, `IS NOT NULL`

### NULL у запитах: три пастки

1. `= NULL` ніколи не спрацює. Порівняння з NULL дає не `TRUE`/`FALSE`, а `UNKNOWN`, і `WHERE`
пропускає лише `TRUE`:
```sql
SELECT * FROM student WHERE end_date = NULL;   -- 0 рядків ЗАВЖДИ, навіть якщо end_date порожній
SELECT * FROM student WHERE end_date IS NULL;  -- правильно
```

2. `NOT IN` + NULL "з'їдає" рядки. Саме тому в запиті нижче знадобилось `OR ... IS NULL`:
```sql
SELECT * FROM professor
WHERE job NOT IN ('доцент', 'професор') OR job IS NULL;
```
Без другої умови викладачі з `job IS NULL` зникнуть: `NULL NOT IN (...)` - це `UNKNOWN`.
Ще небезпечніше, коли NULL всередині самого списку: `x NOT IN (1, 2, NULL)` не повертає нічого
і ніколи, бо `x <> NULL` - `UNKNOWN`.

3. Агрегати ігнорують NULL.
```sql
SELECT count(*)      FROM enrolment;  -- усі рядки
SELECT count(grade)  FROM enrolment;  -- лише рядки, де оцінка вже є
SELECT avg(grade)    FROM enrolment;  -- сума / кількість НЕпорожніх, а не / count(*)
```
Тобто `avg` тут не вважає відсутню оцінку нулем.

### Сортування:
```sql
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC] [NULLS FIRST|LAST]
```
У PostgreSQL NULL за замовчуванням вважається "найбільшим": `ORDER BY grade` ставить NULL у кінець,
а `ORDER BY grade DESC` - на початок. `NULLS FIRST|LAST` існує саме щоб не залежати від цього
замовчування.

### Обмеження результату: LIMIT / OFFSET
```sql
SELECT * FROM student ORDER BY student_id LIMIT 10;            -- перші 10
SELECT * FROM student ORDER BY student_id LIMIT 10 OFFSET 20;  -- третя "сторінка"
```
`LIMIT` майже завжди має йти разом з `ORDER BY`: без сортування порядок рядків не визначений, і
"перші 10" можуть щоразу бути різними.

### Функції агрегації
- `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.
- Агрегують дані та повертають один рядок на всю вибірку (з `GROUP BY` - по одному рядку на групу,
  див. [лекцію 06](../06%20-%20GROUP%20BY%20and%20window%20functions/lecture_notes.md)).

Приклад:
```sql
SELECT COUNT(*) FROM student;
SELECT COUNT(DISTINCT group_id) FROM student;
```

`FILTER (WHERE ...)` - обмежує рядки для одного конкретного агрегату (на відміну від `WHERE`, який відкидає рядки для всього запиту):
```sql
SELECT
    count(*)                                   AS total,
    count(*) FILTER (WHERE grade >= 60)        AS passed,
    count(*) FILTER (WHERE grade <  60)        AS failed,
    count(*) FILTER (WHERE grade IS NULL)      AS not_graded,
    avg(grade) FILTER (WHERE grade >= 60)      AS avg_passing_grade
FROM enrolment;
```
Одним проходом по таблиці - п'ять різних відповідей. Це стандартний SQL (SQL:2003); класична
альтернатива, яка працює всюди - `count(CASE WHEN grade >= 60 THEN 1 END)`.

## 4. UPDATE
```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

### Основні особливості UPDATE:
- Якщо `WHERE` не вказати - оновляться **всі рядки** таблиці.
- Можна оновлювати кілька колонок одночасно:
  ```sql
  UPDATE student
  SET
    course = 3,
    status = 'навчається',
    group_id = (SELECT group_id FROM student_group WHERE name = 'ІТ-12')
  WHERE student_id = 1;
  ```

### Безпечні практики:
- Спочатку перевірте, які рядки будуть оновлені, за допомогою `SELECT`.
- Виконуйте небезпечні зміни у явній транзакції - так помилку ще можна скасувати:
  ```sql
  BEGIN;
  UPDATE student SET group_id = 7 WHERE group_id = 3;
  -- 12 rows affected - а очікували 2? Значить WHERE неправильний:
  ROLLBACK;   -- нічого не змінилось
  -- якщо все правильно:
  COMMIT;
  ```
- `RETURNING` показує, що саме змінилось, не роблячи окремий `SELECT`:
  ```sql
  UPDATE student SET group_id = 7 WHERE group_id = 3 RETURNING student_id, group_id;
  ```
- Пам'ятайте: доки транзакція відкрита, змінені рядки заблоковані для інших. Не лишайте `BEGIN`
  без `COMMIT`/`ROLLBACK` - детальніше в [лекції 10](../10%20-%20Transactions/lecture_notes.md).
- Помилка в запиті переводить транзакцію в стан "aborted", і далі працює тільки `ROLLBACK`.

---

## 5. DELETE
```sql
DELETE FROM table_name
WHERE condition;
```

### Основні особливості DELETE:
- Якщо не вказати `WHERE` - видаляються **УСІ рядки** таблиці.
- DELETE видаляє рядки, але не скидає лічильники автоінкременту.

### TRUNCATE - швидке видалення всіх даних:
```sql
TRUNCATE TABLE student RESTART IDENTITY CASCADE;
```
- Видаляє всі рядки з таблиці, не перевіряючи їх по одному - тому не спрацьовують тригери
  `ON DELETE` для рядків і не рахується кількість видалених рядків.
- Працює значно швидше, ніж `DELETE` без `WHERE`, і одразу звільняє місце на диску (`DELETE` лише
  позначає рядки як видалені - детальніше в
  [лекції 14](../14%20-%20Data%20storage%20on%20disk/lecture_notes.md)).
- Не скидає лічильники автоінкременту - для цього потрібно явно вказати `RESTART IDENTITY`.
- Якщо на таблицю посилаються зовнішні ключі, PostgreSQL відмовиться її очищати:
  ```
  ERROR: cannot truncate a table referenced in a foreign key constraint
  HINT:  Truncate table "enrolment" at the same time, or use TRUNCATE ... CASCADE.
  ```
  `CASCADE` очистить і залежні таблиці - тобто це небезпечніша команда, ніж виглядає.
- У PostgreSQL TRUNCATE транзакційний: усередині `BEGIN ... ROLLBACK` він відкотиться повністю.
  (У деяких інших СУБД - наприклад, у MySQL/InnoDB або Oracle - це DDL з неявним commit, і
  відкотити його не вийде.)
- Бере `ACCESS EXCLUSIVE` lock: доки TRUNCATE не завершиться, таблицю не можна навіть читати.

Саме тому в `scripts/insert-data.sql` стоїть
`TRUNCATE TABLE ... RESTART IDENTITY CASCADE` - обидва ключові слова там не випадкові.

### Безпечні практики:
- Спочатку перевірте, які рядки будуть видалені, за допомогою `SELECT`.
- Небезпечний `DELETE` виконуйте у транзакції (див. §4).
- Розгляньте можливість використання "м'якого видалення" (soft delete) замість фізичного:
  ```sql
  -- Припустимо, що ми додали колонку is_deleted до таблиці student
  UPDATE student SET is_deleted = TRUE WHERE student_id = 1;
  ```
  Але у soft delete є ціна, про яку варто знати заздалегідь: після цього кожен запит мусить
  містити `WHERE NOT is_deleted`, інакше "видалені" дані вилізуть у результатах запитів.
  Тому одразу після введення soft delete зручно зробити представлення
  `CREATE VIEW student_active AS SELECT * FROM student WHERE NOT is_deleted;` і працювати з ним.

---

## 6. Практична частина лекції

Демонстрація виконується на базі, створеній у [лекції 03](../03%20-%20Tables,%20rows,%20columns/lecture_notes.md)
скриптом [create-campus-tables.sql](../../scripts/create-campus-tables.sql) і наповненій
синтетичними даними з [insert-data.sql](../../scripts/insert-data.sql).

Усі константи-`id` у запитах нижче свідомо прибрані: потрібні ключі шукаються підзапитом за
природним ключем (email, назва курсу, назва групи) або повертаються через `RETURNING`. Так запити
відтворюються на будь-якій копії бази.

### CREATE

```sql
<TBD>
```

### READ

```sql
SELECT * FROM enrolment WHERE course_id = 13;

-- знайти всіх студентів 121 спеціальності
SELECT * FROM student WHERE profession = 121;

-- знайти всіх студентів БЕЗ спеціальності
SELECT * FROM student WHERE profession IS NULL;

-- знайти всі не активні курси
SELECT * FROM course WHERE NOT is_active;

-- знайти всі групи потоку ІТ-1Х
SELECT * FROM student_group;
SELECT * FROM student_group WHERE name LIKE 'ІТ-1%';

-- знайти всіх викладачів, у кого рівень кваліфікації нижчий доктора філософії
SELECT * FROM teacher WHERE qualification NOT IN ('доктор філософії', 'доктор наук') OR qualification IS NULL;

-- порахувати середній бал студентів хто успішно здав сесію
SELECT AVG(grade) FROM enrolment WHERE grade >= 60;

-- порахувати який відсоток студентів не склав сесію
SELECT
    count(distinct student_id) FILTER (WHERE grade is null OR grade < 60) as failed_students_count,
    count(distinct student_id) as total_students_count,
    (
        count(distinct student_id) FILTER (WHERE grade is null OR grade < 60) /
		count(distinct student_id)::real
        ) * 100 as failed_percent
FROM enrolment;
```

### UPDATE

```sql
-- перевести студентів з МА-92 до ПС-91
SELECT * from student_group where NAME in ('МА-92', 'ПС-91');
select * from student where group_id = 3;
update student set group_id = 7 WHERE group_id = 3;

-- деактивувати курс комп мереж
select * from course;
update course set is_active = FALSE where course_id = 10;
```

### DELETE

```sql
-- видалити курс з кібербезпеки
select * from course;
delete from course where course_id = 12;
```

Всі запити також можна знайти у [файлі](../../scripts/crud.sql). Файл містить `UPDATE`/`DELETE`,
обгорнуті в `BEGIN; ... ROLLBACK;`, тому його можна запускати цілком, не псуючи дані.

---

## 7. Висновки
- SQL забезпечує стандартний спосіб роботи з даними, але кожна СУБД має свій діалект.
- Основна робота з базою даних - це написання запитів; переважна більшість запитів у типовому
  застосунку - це читання (`SELECT`).
- NULL - не значення, а "невідомо": `= NULL`, `NOT IN` і агрегати поводяться з ним інакше, порівняно зі звичайними значеннями.
- Важливо перевіряти результати перед виконанням операцій, що змінюють дані (`UPDATE`, `DELETE`)
  та виконувати їх у явній транзакції.

## 8. Додаткові матеріали
- [Mode Analytics SQL Tutorial](https://mode.com/sql-tutorial/)
- [SQLZoo - Interactive SQL Exercises](https://sqlzoo.net/)
