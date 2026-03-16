# Лекція 7: Підзапити та CTE (Common Table Expressions)

## Теми лекції

- Підзапити (subqueries) та їх типи
- Корельовані та некорельовані підзапити
- Оператор EXISTS
- Common Table Expressions (CTE)
- Рекурсивні CTE

---

## 1. Вступ
Підзапит (subquery) - це запит, який вкладено всередину іншого SQL-запиту. Він може бути частиною операторів `SELECT`, `FROM`, `WHERE`, `HAVING`.  
Підзапит може повертати різні типи результатів - одне значення, один стовпець, один рядок або цілу таблицю.

Основна ідея: результати одного запиту можуть бути використані в іншому запиті для фільтрації, порівняння або обчислення.

---

## 2. Основні властивості підзапитів
- Підзапити виконуються **перед основним запитом**.
- Результати підзапиту зберігаються в пам'яті, після чого використовуються зовнішнім запитом.
- Підзапит завжди береться у дужки `()`.
- Якщо підзапит знаходиться в частині `FROM`, йому обов'язково потрібно призначити псевдонім (alias).

---

## 3. Навіщо потрібні підзапити
Підзапити зручні:
- для динамічної фільтрації (наприклад, "оцінки вище середнього");
- для роботи з агрегованими даними без виконання кількох запитів;
- для перевірки існування записів (`EXISTS`);
- для спрощення логіки запиту, коли `JOIN` виглядає занадто складно.

Підзапити не замінюють `JOIN`, але часто є зручнішими для читання.

---

## 4. Переваги використання підзапитів
- Менше запитів до бази даних -> зниження мережевих накладних витрат.
- Підвищення консистентності даних, адже підзапит виконується в межах виконання основного запиту та відсутня значна затримка між обчисленням підзапиту та основного запиту.
- Код стає читабельнішим, якщо запит побудовано логічно.

---

## 5. Типи підзапитів
1. Скалярний (scalar subquery) - повертає одне значення (1 рядок, 1 стовпець).
   ```sql
    SELECT student_id, course_id, grade
    FROM enrolment
    WHERE grade > (
        SELECT AVG(grade) FROM enrolment
    );
   ```
2. Колонковий (column subquery) - повертає один стовпець із кількома рядками.
   Використовується з операторами `IN`, `ANY`, `ALL`.
   ```sql
    SELECT student_id, course_id, grade
    FROM enrolment
    WHERE course_id IN (
        SELECT course_id FROM course WHERE student_year = 2
    );
   ```

3. Рядковий (row subquery) - повертає один рядок з кількома стовпцями.

4. Табличний (table subquery) - повертає цілу таблицю (кілька рядків і стовпців), часто використовується у частині `FROM`.
   ```sql
    SELECT s.name, s.surname, avg_student_grade.avg_grade
    FROM (
        SELECT student_id, AVG(grade) as avg_grade
        FROM enrolment
        GROUP BY student_id
    ) AS avg_student_grade
    INNER JOIN student s USING (student_id)
    WHERE avg_student_grade.avg_grade > 90;
   ```

---

## 6. Корельовані та некорельовані підзапити
- Некорельований підзапит - не залежить від зовнішнього запиту; виконується один раз.
- Корельований підзапит - використовує значення зі зовнішнього запиту; виконується для кожного рядка зовнішнього запиту.  
  Це робить його **повільним**, тому варто уникати, коли можливо.

### Приклад корельованого підзапиту
```sql
SELECT *
FROM enrolment e
WHERE grade > (
    SELECT AVG(grade)
    FROM enrolment e2
    WHERE e.course_id = e2.course_id
);
```

---

## 7. Оператор `EXISTS`
- Повертає `TRUE`, якщо підзапит повернув хоча б один рядок.
- Ефективний, оскільки виконує підзапит до першого збігу, а не повністю.
- Використовується переважно з корельованими підзапитами.
- Типовий запис:
  ```sql
  SELECT * 
  FROM course c
  WHERE EXISTS (
      SELECT 1 
      FROM enrolment e 
      WHERE e.course_id = c.course_id
  );
  ```

> Повернення `SELECT 1` - це конвенція. Важливо лише, що підзапит повертає хоча б один рядок, а не конкретне значення.

---

## 8. Common Table Expressions (CTE)

CTE (Common Table Expression) - це іменований тимчасовий набір даних, що існує протягом виконання запиту.  
CTE схожі на підзапити, але:
- вони читаються зручніше;
- можуть бути використані кілька разів у межах одного запиту;
- дозволяють будувати рекурсивні запити.

Синтаксис:
```sql
WITH cte_name AS (
    SELECT ...
)
SELECT ...
FROM cte_name;
```

`WITH` - ключове слово, що позначає CTE.

### Приклад CTE
```sql
WITH avg_student_grade AS (
    SELECT student_id, AVG(grade) as avg_grade
    FROM enrolment
    GROUP BY student_id
)
SELECT s.name, s.surname, asg.avg_grade
FROM avg_student_grade asg
         INNER JOIN student s USING (student_id)
WHERE asg.avg_grade > 90;
```

Пояснення:
- `avg_student_grade` - це CTE, який створює тимчасову таблицю із середніми оцінками.
- Далі вона використовується у головному запиті як звичайна таблиця.
- На відміну від підзапитів у `FROM`, CTE робить структуру запиту логічно зрозумілою та легшою для підтримки.

## 9. Рекурсивні CTE
CTE також підтримують рекурсію - коли вираз звертається сам до себе.
```sql
WITH RECURSIVE cte_name AS (
    SELECT ...      -- базовий випадок
    UNION ALL
    SELECT ...
    FROM cte_name   -- рекурсивне посилання
)
SELECT * FROM cte_name;
```

Приклад - ієрархічна структура пререквізитів курсів, з якою можна працювати рекурсивно:
```sql
WITH RECURSIVE course_dependencies AS (
    SELECT course_id, 1 as level
    FROM course c
    WHERE NOT EXISTS (SELECT 1 FROM course_prerequisite p WHERE p.course_id = c.course_id)
    UNION ALL
    SELECT p.course_id as course_id, cd.level + 1 as level
    FROM course_prerequisite p
             INNER JOIN course_dependencies cd ON p.prerequisite_course_id = cd.course_id
)
SELECT c.name, cd.level
FROM course c INNER JOIN course_dependencies cd USING (course_id);
```
Даний запит поверне курси та глибину їх залежностей (наприклад "Основи програмування" матимуть level 1, адже цей курс ні на який інший не залежить, в той час як "Інженерія ПЗ" матиме level 3, оскільки має глибину залежностей 3).

---

## 10. Відмінності між підзапитами та CTE
| Ознака | Підзапит | CTE |
|--------|-----------|------|
| Розташування | Усередині запиту | Оголошується перед основним запитом |
| Читабельність | Може бути складною при вкладенні | Легко читається, зрозуміла структура |
| Повторне використання | Не можна | Можна використовувати кілька разів |
| Рекурсія | Не підтримується | Підтримується |

---

## 11. Коли краще використовувати CTE
- Коли запит містить кілька вкладених підзапитів.
- Коли потрібно використати один результат кілька разів.
- Для розбиття складного запиту на логічні частини.
- Для роботи з рекурсивними ієрархічними структурами.

---

## 12. Рекомендації
- Завжди надавайте перевагу простішому та зрозумілішому запиту.
- Для складних або багатоетапних запитів - використовуйте CTE.
- Використовуйте СТЕ, якщо запит використовує одні і ті ж обчислення кілька разів.
- Не використовуйте корельовані підзапити (окрім EXISTS), якщо можна використати `JOIN`.
- Використовуйте рекурсивні СТЕ для обробки ієрархічних даних.
- Для перевірки існування даних - використовуйте `EXISTS`.
- Для фільтрації множини значень - `IN`, `ANY`, `ALL`.

---

## 13. Практична частина лекції

Для демонстрації запитів під час лекції, попередньо було підготовано синтетичні дані, запити знаходяться у [файлі](../../scripts/insert-data.sql).

Під час лекції було розроблено наступні запити:

```sql
-- Знайти всі курси, які не мають пререквізитів

select * 
from course c
where not exists (
	select 1 from course_prerequisite p where c.course_id = p.course_id
);

select c.* 
from course c 
left join course_prerequisite p using (course_id)
where p.course_id is null;

-- СТЕ
-- Знайти всі активні предмети для 2 курсу та кількість записаних студентів

with active_courses as (
	select * from course c
	where status = 'активний'
),
second_year_students as (
	select student_id, course_id 
	from enrolment e where start_year = 2024 
)
select ac.name, count(distinct sys.student_id) as student_count
from active_courses ac left join second_year_students sys using (course_id)
group by ac.name
having count(distinct sys.student_id) > 0;

-- Для кожного викладача знайти кількість курсів, які він викладає та середній бал студентів, які відвідували курси
with courses_stats as (
    select professor_id, count(distinct course_id) as number_of_courses
    from course_teacher ct
    group by professor_id
),
grades_stats as (
    select professor_id, avg(grade) as avg_student_grade
    from enrolment e
    inner join course_teacher ct USING (course_id)
    group by professor_id
)
select p.*, cs.number_of_courses, gs.avg_student_grade
from professor prof
         inner join courses_stats cs using (professor_id)
         inner join grades_stats gs using (professor_id)
         inner join person p using (person_id);

-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись

with RECURSIVE course_dependencies as (
    -- initial CASE
    select course_id, 1 as level
    from course c
    where not exists (
        select 1 from course_prerequisite pr where pr.course_id = c.course_id
    )
    UNION ALL
    -- recursive step
    select pr.course_id, cd.level + 1 as level
    from course_dependencies cd
             inner join course_prerequisite pr on cd.course_id = pr.prerequisite_course_id
)
select c.name, max(cd.level) as min_semester
from course_dependencies cd
         inner join course c using (course_id)
group by c.name;
```

Всі запити також можна знайти у [файлі](../../scripts/subqueries.sql).

---

## Вправи на додаткові бали

У [файлі](../../exercises/excercises-subqueries.sql) знаходяться вправи, які можна виконати для отримання додаткових балів.
Виконані вправи можна надіслати викладачу в особисті в телеграмі, або ж оформити у вигляді `pull request` до даного репозиторію.
