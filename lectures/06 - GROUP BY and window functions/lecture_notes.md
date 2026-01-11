# Лекція: Агрегація, групування та віконні функції в SQL

## 1. Функції агрегації

Функції агрегації - це функції, які працюють над множиною рядків і повертають одне агреговане значення.  
Приклади таких функцій:
- `COUNT()` - підраховує кількість рядків;
- `MAX()` - повертає максимальне значення;
- `MIN()` - повертає мінімальне значення;
- `AVG()` - повертає середнє значення;
- `SUM()` - обчислює суму.

Функції агрегації застосовуються до певного набору даних і повертають один рядок результату.
Наприклад:
```sql
SELECT AVG(grade)
FROM enrolment;
```
Цей запит повертає середній бал усіх студентів за всі предмети.

---

## 2. Необхідність групування даних

Іноді потрібно не просто обчислити загальне середнє, а отримати окреме середнє для кожної групи (наприклад, для кожного студента або кожного курсу).  
Для цього використовується оператор `GROUP BY`.

### Призначення `GROUP BY`
`GROUP BY` дозволяє об'єднати рядки у групи за певними колонками, щоб виконати агрегацію в межах кожної групи.

Синтаксис:
```sql
SELECT column_name, AGGREGATE_FUNCTION(column_name)
FROM table_name
GROUP BY column_name;
```

### Приклад
Обчислимо середній бал для кожного курсу:
```sql
SELECT course_id, AVG(grade)
FROM enrolment
GROUP BY course_id;
```
Результат: кожен рядок - це курс і його середній бал.

---

## 3. Використання `HAVING`

Оператор `HAVING` використовується для фільтрації результатів агрегації.  
На відміну від `WHERE`, який фільтрує рядки до групування, `HAVING` застосовується після.

### Приклад
Знайти курси, де середній бал > 90:
```sql
SELECT course_id, AVG(grade) AS avg_grade
FROM enrolment
GROUP BY course_id
HAVING AVG(grade) > 90;
```

---

## 4. Порядок виконання SQL-запиту з `GROUP BY`

1. FROM – об'єднання таблиць (`JOIN`) і вибір базових даних.  
2. WHERE – фільтрація окремих рядків.  
3. GROUP BY – групування даних.  
4. HAVING – фільтрація груп.  
5. SELECT – формування вихідних колонок (включно з агрегаціями).  
6. ORDER BY – сортування результатів.

---

## 5. Обмеження при `GROUP BY`

У запиті з `GROUP BY` у частині `SELECT` можна вказувати лише:
- колонки, які використовуються в `GROUP BY`;
- або результати агрегацій.

Інші колонки, не зазначені в групуванні чи агрегації, не можна вивести напряму, оскільки вони не матимуть однозначного значення.

---

## 6. Віконні функції

Віконні функції (window functions) дозволяють отримувати результати агрегації без втрати окремих рядків.  
Вони застосовуються до "вікна" рядків (певної підмножини), але не об'єднують їх, як `GROUP BY`.

### Синтаксис
```sql
AGGREGATE_FUNCTION(column_name)
OVER (PARTITION BY column_name ORDER BY column_name)
```

### Приклад
Порівняти оцінку кожного студента із середньою оцінкою по предмету:
```sql
SELECT
    s.name AS student_name,
    c.name AS course_name,
    e.grade,
    AVG(e.grade) OVER (PARTITION BY e.course_id) AS avg_course_grade
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
JOIN course c ON e.course_id = c.course_id;
```

Кожен рядок покаже:
- оцінку конкретного студента,
- середній бал по предмету (однаковий для всіх студентів цього курсу).

---

## 7. `OVER()` без параметрів

Якщо викликати `OVER()` без `PARTITION BY`, функція працює по всій таблиці.

```sql
SELECT
    s.name AS student_name,
    e.grade,
    AVG(e.grade) OVER () AS avg_global_grade
FROM enrolment e
JOIN student s ON e.student_id = s.student_id;
```

Усі рядки отримають одне й те саме середнє значення.

---

## 8. `PARTITION BY` у віконних функціях

`PARTITION BY` визначає, як розділити дані на групи (подібно до `GROUP BY`), але не об'єднує їх у один рядок.

---

## 9. `ORDER BY` у віконних функціях

У межах кожної "партиції" (`PARTITION BY`) можна визначити порядок рядків.  
Це дозволяє використовувати функції ранжування.

---

## 10. Функції ранжування (Ranking Functions)

- `ROW_NUMBER()` - номер рядка у межах вікна;
- `RANK()` - ранг із можливими пропусками;
- `DENSE_RANK()` - ранг без пропусків.

```sql
SELECT
    s.name AS student_name,
    c.name AS course_name,
    e.grade,
    DENSE_RANK() OVER (PARTITION BY e.course_id ORDER BY e.grade DESC) AS rank_in_course
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
JOIN course c ON e.course_id = c.course_id;
```

Результат: студенти відсортовані за балами у межах курсу, кожен має свій ранг.

---

## 11. Основні відмінності між `GROUP BY` і `OVER()`

| Ознака | `GROUP BY` | `OVER()` |
|--------|-------------|-----------|
| Результат | Один рядок на групу | Усі рядки з доданою колонкою |
| Мета | Агрегація даних | Аналітика в межах групи |
| Фільтрація груп | `HAVING` | `WHERE` або інші умови |
| Сортування в межах груп | Немає | Можна через `ORDER BY` |

---

## 12. Висновки

- `GROUP BY` потрібен для підсумкової статистики (зведення даних).  
- `HAVING` - для фільтрації після агрегації.  
- Віконні функції (`OVER`) дають змогу поєднати індивідуальні рядки та агреговані значення в одному запиті.  
- `PARTITION BY` задає межі груп для вікна.  
- `ORDER BY` у віконній функції впливає на результати функцій ранжування, зокрема `ROW_NUMBER()`.

---

## 13. Практична частина лекції

Для демонстрації запитів підчас лекції, попередньо було підготовано синтетичні дані, запити знаходяться у [файлі](../../scripts/insert-data.sql).

Підчас лекції було розроблено наступні запити:

```sql
-- порахувати розміри груп
SELECT group_id, g.name, count(student_id) as group_size
FROM student_group g LEFT JOIN student s USING (group_id)
GROUP BY group_id, g.name
ORDER BY g.name;

-- порахувати навантаження викладачів - скільки активних курсів та кредитів викладає кожен з викладачів
SELECT
    t.name || ' ' || t.surname as full_name,
    count(course_id) as number_of_courses,
    sum(credits) as sum_of_credits
FROM teacher t LEFT JOIN course c USING(teacher_id)
WHERE is_active
GROUP BY t.teacher_id, t.name, t.surname
ORDER BY sum_of_credits DESC, full_name ASC;

-- знайти усіх студентів, середній бал яких більше 90
SELECT
    s.name || ' ' || s.surname as full_name,
    ROUND(AVG(grade), 1) as avg_grade
FROM student s INNER JOIN enrolment e USING (student_id)
WHERE grade is not null
GROUP BY s.name, s.surname
HAVING AVG(grade) > 90
ORDER BY avg_grade DESC;

-- отримати оцінки студентів у порівнянні з середнім балом по предмету
-- додати середній бал студента
SELECT
    s.name || ' ' || s.surname as full_name,
    c.name as course_name,
    grade,
    ROUND(AVG(grade) OVER (PARTITION BY course_id), 1) as avg_course_grade,
    ROUND(AVG(grade) OVER (PARTITION BY student_id), 1) as avg_student_grade
FROM student s INNER JOIN enrolment e USING (student_id) INNER JOIN course c USING (course_id)
WHERE grade is not null
ORDER BY full_name ASC;


-- побудувати список за успішністю по групам
SELECT
    s.name || ' ' || s.surname as full_name,
    g.name as group_name,
    ROUND(COALESCE(AVG(grade), 0), 1) as avg_student_grade,
    row_number() over (PARTITION BY g.name ORDER BY COALESCE(AVG(grade), 0) DESC) as student_rank
FROM student s
         INNER JOIN enrolment e USING (student_id)
         INNER JOIN student_group g USING (group_id)
GROUP BY s.name, s.surname, g.name
ORDER BY group_name ASC, student_rank ASC;

-- порахувати успішність студентів залежно від року навчання
--
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
--
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
```

Всі запити також можна знайти у [файлі](../../scripts/aggregations.sql).

---

## Вправи на додаткові бали

У [файлі](../../exercises/excercises-groupby.sql) знаходяться вправи, які можна виконати для отримання додаткових балів.
Виконані вправи можна надіслати викладачу в особисті в телеграмі, або ж оформити у вигляді `pull request` до даного репозиторію.
