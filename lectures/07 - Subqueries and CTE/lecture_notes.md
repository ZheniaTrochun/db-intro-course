# Лекція 7: Підзапити та CTE (Common Table Expressions)

## Теми лекції

- Підзапити (subqueries): де вони можуть стояти і які бувають
- Оператори `IN`, `ANY`, `ALL`, `EXISTS`
- Корельовані та некорельовані підзапити
- Common Table Expressions (CTE)
- Рекурсивні CTE

Усі приклади написано для схеми з [create-campus-tables.sql](../../scripts/create-campus-tables.sql) і даних з [insert-data.sql](../../scripts/insert-data.sql).
Наведені результати отримано саме на цих даних.

---

## 1. Вступ

Підзапит (subquery, вкладений запит) - це запит, вкладений всередину іншого SQL-запиту.
Підзапит завжди береться у дужки `()`.

Основна ідея: результат одного запиту використовується в іншому запиті для фільтрації, порівняння або обчислення.

Наприклад, потрібно знайти записи на курси, де оцінка вища за середню. Середню оцінку заздалегідь невідомо,
тому її обчислює підзапит:
```sql
SELECT student_id, course_id, grade
FROM enrolment
WHERE grade > (
    SELECT AVG(grade) FROM enrolment
);
```
Підзапит повертає одне число (77.31), і зовнішній запит порівнює з ним кожен рядок. Результат: 99 записів.

Без підзапиту довелося б виконати два окремі запити і вручну підставити число з першого в другий.

---

## 2. Де може стояти підзапит

Підзапит може бути частиною різних частин оператора `SELECT`:

| Частина  | Що повертає підзапит                     | Приклад                                      |
|----------|------------------------------------------|----------------------------------------------|
| `WHERE`  | значення або набір значень для умови     | `WHERE grade > (SELECT AVG(grade) ...)`      |
| `SELECT` | одне значення для кожного рядка          | `SELECT ..., (SELECT COUNT(*) ...) AS cnt`   |
| `FROM`   | таблицю, з якою працюють як зі звичайною | `FROM (SELECT ... GROUP BY ...) AS t`        |
| `HAVING` | значення для умови на групу              | `HAVING AVG(grade) > (SELECT AVG(grade) ...)` |

Крім того, підзапити можна використовувати в `JOIN ... ON`, а також в операторах `INSERT`, `UPDATE`, `DELETE`.

Підзапит у `SELECT`: кількість записів на кожен курс.
```sql
SELECT c.course_name,
       (SELECT COUNT(*) FROM enrolment e WHERE e.course_id = c.course_id) AS enrolments
FROM course c
ORDER BY c.course_id;
```
```
         course_name          | enrolments
------------------------------+------------
 Програмування                |         35
 Математичний аналіз          |         35
 Дискретна математика         |         35
 Алгоритми та структури даних |         28
 ...
```

Підзапит у `HAVING`: курси, середній бал яких вищий за загальний середній бал.
```sql
SELECT c.course_name, ROUND(AVG(e.grade), 2) AS avg_grade
FROM enrolment e
    JOIN course c USING (course_id)
GROUP BY c.course_id, c.course_name
HAVING AVG(e.grade) > (SELECT AVG(grade) FROM enrolment)
ORDER BY avg_grade DESC;
```
```
    course_name     | avg_grade
--------------------+-----------
 Хмарні технології  |     86.00
 Операційні системи |     81.38
 Машинне навчання   |     80.78
 Кібербезпека       |     79.83
 Програмування      |     78.46
```

---

## 3. Типи підзапитів

За формою результату розрізняють чотири типи підзапитів.

### 3.1. Скалярний підзапит

Скалярний підзапит (scalar subquery) повертає одне значення: 1 рядок і 1 колонку.
Його можна використовувати всюди, де очікується одне значення: в умові, у `SELECT`, в обчисленні.
```sql
SELECT student_id, course_id, grade,
       ROUND((SELECT AVG(grade) FROM enrolment), 2) AS avg_grade
FROM enrolment;
```
```
 student_id | course_id | grade | avg_grade
------------+-----------+-------+-----------
          1 |         1 |    61 |     77.31
          1 |         2 |    94 |     77.31
          1 |         3 |    77 |     77.31
 ...
```

Важливо знати, що відбувається, якщо підзапит повертає не рівно один рядок:
- якщо рядків більше одного, запит завершується помилкою:
  ```
  ERROR:  more than one row returned by a subquery used as an expression
  ```
- якщо рядків немає, результатом підзапиту стає `NULL`, без помилки

Тому скалярний підзапит варто будувати так, щоб він гарантовано повертав не більше одного рядка,
наприклад через агрегат (`AVG`, `MAX`, `COUNT`) або умову за первинним ключем.

### 3.2. Колонковий підзапит

Колонковий підзапит (column subquery) повертає одну колонку з кількома рядками.
Використовується з операторами `IN`, `ANY`, `ALL` (розділ 4).
```sql
-- записи на курси з 6 і більше кредитами
SELECT student_id, course_id, grade
FROM enrolment
WHERE course_id IN (
    SELECT course_id FROM course WHERE credits >= 6
);
```
Результат: 181 запис.

### 3.3. Рядковий підзапит

Рядковий підзапит (row subquery) повертає один рядок з кількома колонками.
Його порівнюють з набором значень, записаним у дужках:
```sql
-- студенти з найвищою оцінкою на курсі "Дискретна математика" (course_id = 3)
SELECT student_id, course_id, grade
FROM enrolment
WHERE (course_id, grade) = (
    SELECT course_id, MAX(grade)
    FROM enrolment
    WHERE course_id = 3
    GROUP BY course_id
);
```
```
 student_id | course_id | grade
------------+-----------+-------
          2 |         3 |    99
         21 |         3 |    99
         30 |         3 |    99
```

### 3.4. Табличний підзапит

Табличний підзапит (table subquery) повертає набір рядків і колонок. Найчастіше він стоїть у `FROM`,
і зовнішній запит працює з ним як зі звичайною таблицею.
```sql
-- студенти із середнім балом понад 85
SELECT p.first_name, p.last_name, ROUND(asg.avg_grade, 2) AS avg_grade
FROM (
    SELECT student_id, AVG(grade) AS avg_grade
    FROM enrolment
    GROUP BY student_id
) AS asg
    JOIN student s USING (student_id)
    JOIN person p USING (person_id)
WHERE asg.avg_grade > 85
ORDER BY asg.avg_grade DESC;
```
```
 first_name | last_name | avg_grade
------------+-----------+-----------
 Мирослава  | Гнатюк    |     97.00
 Максим     | Новенко   |     93.20
 Інна       | Корненко  |     87.00
 Тамара     | Юрченко   |     86.60
 Андріана   | Волошин   |     86.00
 Марта      | Гриценко  |     85.67
```

У стандарті SQL і більшості СУБД підзапит у `FROM` потребує псевдоніма (тут `asg`).
PostgreSQL 16+ дозволяє його не писати, але з псевдонімом запит читабельніший і переноситься на інші СУБД.

---

## 4. Оператори `IN`, `ANY`, `ALL`, `EXISTS`

### `IN`, `ANY`, `ALL`

| Вираз                 | Значення                                                              |
|-----------------------|-----------------------------------------------------------------------|
| `x IN (subquery)`     | `x` дорівнює хоча б одному значенню. Те саме, що `x = ANY (subquery)` |
| `x > ANY (subquery)`  | `x` більше хоча б одного значення                                     |
| `x > ALL (subquery)`  | `x` більше кожного значення                                           |
| `x NOT IN (subquery)` | `x` не дорівнює жодному значенню. Те саме, що `x <> ALL (subquery)`   |

Замість `>` можна використовувати будь-який оператор порівняння.

Дві особливості `ALL`, які легко пропустити:
- `x > ALL (порожній набір)` дорівнює `TRUE` для кожного рядка, навіть якщо `x` є `NULL`
- якщо в наборі є хоча б один `NULL`, `x > ALL (...)` ніколи не дорівнює `TRUE`

### `EXISTS`

`EXISTS (subquery)` повертає `TRUE`, якщо підзапит повернув хоча б один рядок. Значення в рядках не важливі.
Зазвичай `EXISTS` використовується з корельованим підзапитом (розділ 5), тобто з підзапитом, що посилається на
рядок зовнішнього запиту.
```sql
-- студенти, які не записані на жоден курс
SELECT s.student_id, p.first_name || ' ' || p.last_name AS full_name
FROM student s
    JOIN person p USING (person_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM enrolment e
    WHERE e.student_id = s.student_id
);
```
```
 student_id |     full_name
------------+--------------------
         25 | Станіслав Левченко
         40 | Едуард Степаненко
```

> `SELECT 1` у підзапиті `EXISTS` - це конвенція. `SELECT *` працює так само: важлива лише наявність рядка,
> колонки не читаються.

### Пастка: `NOT IN` і `NULL`

`NOT IN` здається природною протилежністю `IN`, але поводиться неочікувано, якщо підзапит повертає `NULL`.
На курсі 7 ("Архітектура компʼютерів") 6 записів, і в усіх `grade` є `NULL`:
```sql
SELECT COUNT(*)
FROM enrolment
WHERE grade NOT IN (SELECT grade FROM enrolment WHERE course_id = 7);
-- 0

SELECT COUNT(*)
FROM enrolment e
WHERE NOT EXISTS (
    SELECT 1 FROM enrolment e2
    WHERE e2.course_id = 7 AND e2.grade = e.grade
);
-- 251
```
`x NOT IN (a, b, NULL)` розкривається в `x <> a AND x <> b AND x <> NULL`. Останній доданок завжди дає `NULL`,
тому вся умова ніколи не дорівнює `TRUE`, і жоден рядок не проходить фільтр.

Тому для перевірки "немає відповідного рядка" варто надавати перевагу `NOT EXISTS`: він не залежить від `NULL`.
`NOT IN` безпечний лише тоді, коли колонка підзапиту не може містити `NULL` (наприклад, `NOT NULL` або первинний ключ).

---

## 5. Корельовані та некорельовані підзапити

Окремо від форми результату, підзапити поділяють за тим, чи залежать вони від зовнішнього запиту:
- некорельований підзапит не посилається на зовнішній запит. Його результат однаковий для всіх рядків,
  і він обчислюється один раз
- корельований підзапит посилається на колонки зовнішнього запиту. Його результат свій для кожного рядка,
  і логічно він обчислюється для кожного рядка зовнішнього запиту

Корельованим може бути підзапит будь-якого типу. Усі приклади з `EXISTS` вище корельовані.

### Приклад корельованого підзапиту

Записи, де оцінка вища за середню на цьому ж курсі:
```sql
SELECT student_id, course_id, grade
FROM enrolment e
WHERE grade > (
    SELECT AVG(grade)
    FROM enrolment e2
    WHERE e2.course_id = e.course_id
);
```
Умова `e2.course_id = e.course_id` посилається на рядок зовнішнього запиту `e`. Результат: 105 записів.

### Як це виконується

Логічно підзапит обчислюється до того, як зовнішній запит використає його результат.
Фізично спосіб виконання обирає планувальник. `EXPLAIN` на даних курсу показує три різні варіанти:
- некорельований скалярний підзапит (розділ 1): `InitPlan`, виконується один раз
- корельований скалярний підзапит (приклад вище): `SubPlan`, виконується 251 раз, по разу на кожен рядок `enrolment`
- `IN` і `EXISTS`: окремого виконання підзапиту немає, планувальник перетворює їх на `JOIN` (semi-join)

Тому твердження "корельований підзапит завжди повільний" неточне. Повільним може бути скалярний корельований підзапит
на великій таблиці. Часто той самий результат можна отримати через `JOIN` з агрегатом або через віконну функцію
з лекції 6. Наступний запит повертає ті самі 105 записів за одне сканування таблиці:
```sql
SELECT student_id, course_id, grade
FROM (
    SELECT e.*, AVG(grade) OVER (PARTITION BY course_id) AS course_avg
    FROM enrolment e
) AS t
WHERE grade > course_avg;
```

---

## 6. Навіщо потрібні підзапити

Підзапити зручні:
- для динамічної фільтрації, коли умова залежить від даних (наприклад, "оцінки вище середнього")
- для роботи з агрегованими даними без кількох окремих запитів
- для перевірки існування записів (`EXISTS`)
- для розбиття складної задачі на кроки, коли один `JOIN` виглядає занадто заплутано

Крім читабельності, один запит з підзапитом має ще дві переваги перед кількома окремими запитами:
- менше звернень до бази даних, а отже менше мережевих накладних витрат
- увесь оператор SQL бачить дані в одному стані (snapshot). Якщо між двома окремими запитами інша транзакція змінить дані,
  результати можуть не узгоджуватися. Усередині одного запиту такого не буває. Детальніше це розглядається в лекції про транзакції.

Підзапити не замінюють `JOIN`, але часто є зручнішими для читання.

---

## 7. Common Table Expressions (CTE)

CTE (Common Table Expression) - це іменований підзапит, оголошений перед основним запитом за допомогою `WITH`.
CTE існує лише в межах одного запиту.

Синтаксис:
```sql
WITH cte_name AS (
    SELECT ...
)
SELECT ...
FROM cte_name;
```

### Приклад CTE

Той самий запит, що і в розділі 3.4, але з CTE:
```sql
WITH avg_student_grade AS (
    SELECT student_id, AVG(grade) AS avg_grade
    FROM enrolment
    GROUP BY student_id
)
SELECT p.first_name, p.last_name, ROUND(asg.avg_grade, 2) AS avg_grade
FROM avg_student_grade asg
    JOIN student s USING (student_id)
    JOIN person p USING (person_id)
WHERE asg.avg_grade > 85
ORDER BY asg.avg_grade DESC;
```
Результат такий самий (6 рядків). Різниця в читанні: проміжний крок має назву і стоїть на початку,
а основний запит читається зверху вниз без вкладень.

### Кілька CTE і повторне використання

В одному `WITH` можна оголосити кілька CTE через кому. Кожен наступний CTE може посилатися на попередні.
На один CTE можна послатися кілька разів, і це головна перевага перед підзапитом у `FROM`, який довелося б повторювати.

Студенти, записані на більшу за середню кількість курсів:
```sql
WITH student_courses AS (
    SELECT student_id, COUNT(*) AS course_number
    FROM enrolment
    GROUP BY student_id
)
SELECT student_id, course_number
FROM student_courses
WHERE course_number > (SELECT AVG(course_number) FROM student_courses)
ORDER BY course_number DESC, student_id;
```
CTE `student_courses` використано двічі: як джерело рядків і в підзапиті для середнього (6.61).
Результат: 21 студент, від студента 31 з 11 курсами до студентів із 7 курсами.

### Як виконується CTE

CTE не обовʼязково створює тимчасову таблицю. З PostgreSQL 12 CTE, на який посилаються один раз,
вбудовується в основний запит так само, як підзапит. Якщо на CTE посилаються кілька разів, PostgreSQL обчислює його
один раз і зберігає результат. Явно керувати цим можна через `WITH name AS MATERIALIZED (...)` і `AS NOT MATERIALIZED`.

Тобто CTE і підзапит у `FROM` відрізняються насамперед читабельністю, а не швидкістю.

---

## 8. Рекурсивні CTE

CTE з ключовим словом `RECURSIVE` може посилатися сам на себе. Це дозволяє обробляти дані, де глибина
звʼязків заздалегідь невідома: ієрархії, графи, ланцюжки залежностей.
```sql
WITH RECURSIVE cte_name AS (
    SELECT ...      -- базовий випадок
    UNION ALL
    SELECT ...
    FROM cte_name   -- рекурсивний крок
)
SELECT * FROM cte_name;
```

### Як виконується рекурсія

1. Виконується базовий запит. Його рядки йдуть у результат і стають "робочою таблицею".
2. Виконується рекурсивний крок, де `cte_name` означає лише рядки попереднього кроку, а не весь накопичений результат.
3. Нові рядки додаються до результату і стають новою робочою таблицею.
4. Коли крок не повертає жодного рядка, рекурсія зупиняється.

### Приклад: ланцюжки пререквізитів

Таблиця `course_prerequisite` зберігає, які курси потрібно пройти перед іншими.
Задача: для кожного курсу знайти довжину ланцюжка пререквізитів, який до нього веде.
```sql
WITH RECURSIVE course_dependencies AS (
    -- базовий випадок: курси без пререквізитів
    SELECT course_id, 1 AS level
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1 FROM course_prerequisite pr WHERE pr.course_id = c.course_id
    )
    UNION ALL
    -- рекурсивний крок: курси, пререквізит яких знайдено на попередньому кроці
    SELECT pr.course_id, cd.level + 1 AS level
    FROM course_dependencies cd
        JOIN course_prerequisite pr ON pr.prerequisite_course_id = cd.course_id
)
SELECT c.course_name, cd.level
FROM course_dependencies cd
    JOIN course c USING (course_id)
ORDER BY cd.level, c.course_name;
```

Покрокове виконання на даних курсу:

| Крок | Нові рядки (`course_id`) | Пояснення |
|---|---|---|
| 1 (базовий) | 1, 2, 3, 6, 7 | Програмування, Математичний аналіз, Дискретна математика, Операційні системи, Архітектура компʼютерів |
| 2 | 4, 5, 8, 9, 11, 12 | курси, пререквізит яких серед курсів кроку 1 |
| 3 | 8, 10 | Машинне навчання (через Алгоритми), Інженерія програмного забезпечення (через ООП) |
| 4 | немає | рекурсія зупиняється |

Результат містить 13 рядків для 12 курсів: "Машинне навчання" зʼявляється двічі, з level 2 і level 3.
Причина в тому, що пререквізити утворюють не дерево, а граф: "Машинне навчання" має два пререквізити,
"Математичний аналіз" (ланцюжок довжиною 2) і "Алгоритми та структури даних" (ланцюжок довжиною 3).
Запит повертає рядок для кожного шляху.

Щоб отримати найдовший ланцюжок для кожного курсу, результат потрібно згрупувати і взяти `MAX(level)`.

`UNION ALL` тут обрано тому, що він не витрачає час на пошук дублікатів. `UNION` прибрав би лише повністю
однакові рядки, а рядки з різним `level` однаковими не є.

### Цикли

Якщо дані містять цикл (курс A вимагає B, а B вимагає A), рекурсивний запит може ніколи не завершитися:
кожен крок знову знаходить нові рядки. Інший можливий наслідок: курси в циклі не мають шляху від курсу без пререквізитів
і тихо зникають з результату.

PostgreSQL 14+ підтримує стандартну конструкцію `CYCLE`, яка зупиняє рекурсію при повторному відвідуванні:
```sql
WITH RECURSIVE course_dependencies AS (
    ...
)
CYCLE course_id SET is_cycle USING path
SELECT * FROM course_dependencies;
```
`is_cycle` позначає рядок, на якому знайдено цикл, а `path` містить пройдений шлях.
Простіший варіант для старіших версій: обмежити глибину умовою `WHERE cd.level < 20` у рекурсивному кроці.

---

## 9. Відмінності між підзапитами та CTE

| Ознака                | Підзапит                               | CTE                                         |
|-----------------------|----------------------------------------|---------------------------------------------|
| Розташування          | усередині запиту                       | оголошується перед основним запитом         |
| Читабельність         | складна при багатьох рівнях вкладення  | читається зверху вниз, кожен крок має назву |
| Повторне використання | потрібно повторювати текст підзапиту   | на CTE можна посилатися кілька разів        |
| Рекурсія              | не підтримується                       | підтримується (`WITH RECURSIVE`)            |
| Швидкодія             | однакова для одноразового використання | однакова для одноразового використання      |

---

## 10. Висновки

- Підзапит може стояти в `WHERE`, `SELECT`, `FROM` і `HAVING`. Скалярний підзапит має повертати не більше одного рядка.
- Для перевірки існування варто надавати перевагу `EXISTS` і `NOT EXISTS`. `NOT IN` повертає порожній результат,
  якщо підзапит містить `NULL`.
- Корельований скалярний підзапит виконується для кожного рядка. Якщо таблиця велика, варто розглянути `JOIN`
  з агрегатом або віконну функцію.
- CTE доречні, коли запит має кілька проміжних кроків або використовує той самий проміжний результат кілька разів.
- Рекурсивні CTE підходять для ієрархічних даних і графів. Для графа з кількома шляхами потрібна агрегація результату,
  а для даних, де можливі цикли, варто додати `CYCLE` або обмеження глибини.
- З кількох рівнозначних варіантів запиту варто надавати перевагу найпростішому і найзрозумілішому.

---

## 11. Практична частина лекції

Для демонстрації запитів під час лекції було підготовлено синтетичні дані, скрипт для їх завантаження знаходиться у [файлі](../../scripts/insert-data.sql).

Під час лекції було розроблено наступні запити:

```sql
-- Знайти всі курси, які не мають пререквізитів
-- Варіант 1: NOT EXISTS
select *
from course c
where not exists (
	select 1 from course_prerequisite cp where cp.course_id = c.course_id
);

-- Варіант 2: LEFT JOIN + IS NULL (результат той самий, 5 курсів)
select *
from course c
	left join course_prerequisite cp on cp.course_id = c.course_id
where cp.prerequisite_course_id is null;


-- Знайти активні курси, на які записані студенти набору 2023 року, та кількість таких студентів

with active_courses as (
  select *
  from course
  where course_status = 'active'
),
     students_2023 as (
       select *
       from student s
              inner join student_group_assignment sga using (student_id)
              inner join student_group sg using (group_id)
       where sg.start_year = 2023
     )
select
  ac.course_name,
  count(*) as num_of_students
from active_courses ac
       inner join enrolment e using (course_id)
       inner join students_2023 using (student_id)
group by ac.course_name;

-- Для кожного викладача знайти кількість курсів, які він викладає,
-- та середній бал студентів, які відвідували ці курси

with courses_stats as (
  select professor_id, COUNT(*) as number_of_courses
    from course_teacher
    group by professor_id
),
grades_stats as (
    select ct.professor_id, AVG(e.grade) as avg_student_grade
    from course_teacher ct
          inner join enrolment e using (course_id)
    group by ct.professor_id
)
select prof.professor_id,
       p.first_name || ' ' || p.last_name as full_name,
       COALESCE(cs.number_of_courses, 0) as number_of_courses,
       ROUND(gs.avg_student_grade, 2) as avg_student_grade
from professor prof
       inner join person p using (person_id)
       left join courses_stats cs using (professor_id)
       left join grades_stats gs using (professor_id)
order by prof.professor_id;


-- Для кожного курсу знайти, в якому мінімальному семестрі він може читатись

with recursive course_dependencies as (

  select course_id, 1 as level
  from course c
  where not exists (
    select 1 from course_prerequisite cp where cp.course_id = c.course_id
  )

  union all

  select cp.course_id, cd.level + 1 as level
  from course_dependencies cd
         inner join course_prerequisite cp on cd.course_id = cp.prerequisite_course_id

)
select c.course_name, max(cd.level) as min_semester
from course_dependencies cd
       inner join course c using (course_id)
group by c.course_id;
```

Всі запити також можна знайти у [файлі](../../scripts/subqueries.sql).

---

## Вправи на додаткові бали

У [директорії](../../exercises) знаходяться вправи, які можна виконати для отримання додаткових балів.
Виконані вправи потрібно оформити у вигляді `pull request` до даного репозиторію.
