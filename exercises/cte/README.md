# CTE (Common Table Expressions) - короткий довідник

> Повний матеріал з прикладами - у [лекції 7](../../lectures/07%20-%20Subqueries%20and%20CTE/lecture_notes.md).
> Цей файл - лише швидке нагадування перед виконанням вправ.

## Що таке CTE?

CTE (Common Table Expression) - це іменований тимчасовий набір даних, що існує лише протягом виконання
одного запиту. По суті - це спосіб дати підзапиту ім'я та винести його "нагору", перед основним запитом.

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT ...
FROM cte_name;
```

- `WITH` - ключове слово, що позначає початок CTE
- В одному запиті можна оголосити кілька CTE через кому
- Кожна наступна CTE може використовувати результати попередніх

```sql
WITH avg_student_grade AS (
    SELECT student_id, AVG(grade) as avg_grade
    FROM enrolment
    GROUP BY student_id
)
SELECT s.first_name, s.last_name, asg.avg_grade
FROM avg_student_grade asg
         INNER JOIN student s USING (student_id)
WHERE asg.avg_grade > 90;
```

## Навіщо потрібні CTE, якщо є підзапити?

CTE і підзапити вирішують схожі задачі, але CTE зручніші:

| Ознака                | Підзапит                             | CTE                                    |
|------------------------|---------------------------------------|------------------------------------------|
| Читабельність          | Важко читати при глибокій вкладеності | Логічна структура "крок за кроком"        |
| Повторне використання  | Не можна                              | Можна звертатись до CTE кілька разів      |
| Рекурсія               | Не підтримується                      | Підтримується (`WITH RECURSIVE`)          |

Використовуйте CTE, коли:
- запит складається з кількох логічних кроків, і хочеться дати кожному кроку назву;
- один і той самий проміжний результат потрібен у кількох місцях запиту;
- потрібно обробити ієрархічні/рекурсивні дані (наприклад, пре-реквізити курсів).

## Рекурсивні CTE

`WITH RECURSIVE` дозволяє CTE звертатися саме до себе - це потрібно для обходу ієрархій
(дерева, графи залежностей тощо), які наперед мають невідому глибину.

```sql
WITH RECURSIVE cte_name AS (
    SELECT ...       -- базовий випадок (anchor) - початкова точка рекурсії
    UNION ALL
    SELECT ...
    FROM cte_name    -- рекурсивний крок - звертається до вже накопичених рядків
)
SELECT * FROM cte_name;
```

Приклад - глибина залежностей курсів від пре-реквізитів:

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

Виконання зупиняється, коли рекурсивний крок перестає повертати нові рядки.

## Практичні поради

- Завжди надавайте перевагу простішому та зрозумілішому запиту - CTE не завжди потрібні.
- Використовуйте CTE, якщо запит використовує одні й ті самі обчислення кілька разів.
- Розбивайте складний запит на кілька логічних CTE замість одного величезного вкладеного запиту.
- Для рекурсивних CTE не забувайте про умову завершення (`UNION ALL` без нових рядків) -
  інакше запит може виконуватись нескінченно довго.
