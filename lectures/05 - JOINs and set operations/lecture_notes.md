# Лекція 5: JOIN та операції над множинами

## Теми лекції

- Операції JOIN між таблицями
- Операції над множинами (SET operations): `UNION`, `INTERSECT`, `EXCEPT`

---

## 2. Що таке JOIN та навіщо це

JOIN - це інструмент для поєднання рядків із двох або більше таблиць на основі логічного зв'язку між ними (зазвичай на основі foreign keys).

У нормалізованих базах даних інформація розподілена по різних таблицях.  
Наприклад:
- Таблиця `student`: `id`, `name`, `surname`, `group_id`
- Таблиця `contact_data`: контактні дані студентів
- Таблиця `student_group`: інформація про академічні групи

Іноді потрібно отримати дані одразу з кількох таблиць - саме тоді застосовують JOIN.

---

## 3. Види JOIN

| Вид JOIN | Опис                                                                                           | Приклад використання                           |
|-----------|------------------------------------------------------------------------------------------------|------------------------------------------------|
| INNER JOIN | Повертає тільки ті рядки, які мають збіги в обох таблицях                                      | Студенти, які мають контактну інформацію       |
| LEFT JOIN (LEFT OUTER JOIN) | Повертає всі рядки з першої таблиці та відповідні з другої; якщо збігів немає - ставить `NULL` | Всі викладачі, навіть ті, що не курують групи  |
| RIGHT JOIN (RIGHT OUTER JOIN) | Дзеркальна версія LEFT JOIN - всі рядки з другої таблиці                                       | Рідко використовується                         |
| FULL OUTER JOIN | Поєднання LEFT і RIGHT JOIN - усі рядки з обох таблиць                                         | Всі студенти та всі групи                      |
| CROSS JOIN | Декартовий добуток двох таблиць (усі комбінації рядків)                                        | Специфічні задачі                              |

---

## 4. INNER JOIN

```sql
SELECT *
FROM student s
INNER JOIN student_group g
ON s.group_id = g.group_id;
```

- `ON` визначає умову поєднання.  
- Результат містить усі колонки обох таблиць, для яких знайдено відповідність.

![img.png](imgs/img.png)

### Альтернатива з `USING`

Якщо колонки мають однакові назви:
```sql
SELECT *
FROM student
INNER JOIN student_group
USING (group_id);
```

---

## 5. LEFT JOIN

```sql
SELECT *
FROM teacher t
LEFT JOIN student_group g
ON t.teacher_id = g.curator_id;
```

- Всі викладачі з'являться у результаті, навіть ті, що не курують групи.  
- Для викладачів без груп - у колонках груп буде `NULL`.

![img_1.png](imgs/img_1.png)

---

## 6. RIGHT JOIN

- Повністю аналогічний до LEFT JOIN, але виводить усі рядки з другої таблиці.
- Зустрічається рідко, оскільки той самий результат можна отримати, просто помінявши таблиці місцями у LEFT JOIN.
- У переважній більшості випадків потрібно надавати перевагу LEFT JOIN.

![img_2.png](imgs/img_2.png)

---

## 7. FULL OUTER JOIN

```sql
SELECT *
FROM student s
FULL OUTER JOIN student_group g
ON s.group_id = g.group_id;
```

- Повертає всі рядки з обох таблиць.
- Якщо відповідності немає - заповнює поля `NULL`.

![img_3.png](imgs/img_3.png)

---

## 8. CROSS JOIN

```sql
SELECT *
FROM table1 t1, table2 t2;
```

- Не має предиката `ON`.
- Кожен рядок з першої таблиці поєднується з усіма рядками другої таблиці.
- Використовується рідко та у специфічних задачах.

![img_4.png](imgs/img_4.png)

---

## 9. Антиджойни (ANTI-JOIN)

- Використовуються для вибірки рядків з першої таблиці, які не мають відповідників у другій.
- Реалізуються через `LEFT JOIN` із додатковою умовою `WHERE second_table.id IS NULL`.

![img_7.png](imgs/img_7.png)

---

## 10. Підтримка JOIN у різних СУБД

- Не всі системи керування базами даних (СУБД) підтримують усі типи JOIN однаково.
- Деякі можуть не мати `FULL OUTER JOIN` або мати свій синтаксис.
- У курсі розглядається PostgreSQL та його синтаксис.

---

## 11. Операції над множинами (SET OPERATIONS)

Операції над множинами - це операції над наборами рядків, а не над атрибутами.

| Операція | Опис |
|-----------|-------|
| UNION | Об'єднання результатів двох запитів |
| INTERSECT | Перетин результатів |
| EXCEPT | Різниця між результатами |

> ⚠️ Всі операції над множинами вимагають, щоб кількість і типи колонок у запитах збігалися.

---

### 11.1. UNION

```sql
SELECT name FROM student
UNION
SELECT name FROM teacher;
```

- Об'єднує результати обох запитів.
- Дублікатні рядки автоматично видаляються.
- Для збереження дублікатів - `UNION ALL`.

![img_3.png](imgs/img_3.png)

---

### 11.2. INTERSECT

```sql
SELECT name FROM student
INTERSECT
SELECT name FROM teacher;
```

- Повертає лише ті рядки, які є в обох множинах.
- Для включення дублікатів - `INTERSECT ALL`.

![img.png](imgs/img.png)

---

### 11.3. EXCEPT

```sql
SELECT name FROM student
EXCEPT
SELECT name FROM teacher;
```

- Повертає рядки, які є у першому наборі, але відсутні у другому.

![img_7.png](imgs/img_7.png)

---

## 12. Порівняння JOIN та SET-операцій

| Критерій | JOIN                                                   | Операції над множинами                 |
|-----------|--------------------------------------------------------|----------------------------------------|
| Працює над | Колонками                                              | Рядками                                |
| Результат | Об'єднання атрибутів                                   | Додавання рядків                       |
| Основна ідея | Поєднання пов'язаних даних                             | Комбінація наборів результатів         |
| Взаємозамінність | SET операції можна виразити через JOIN, але не навпаки | JOIN не виражається через SET операції |

---

## 13. Практичне застосування
- Можна комбінувати багато JOIN в одному запиті (20+ - не проблема).
- JOIN та SET-операції часто застосовуються у звітах, аналітичних вибірках, побудові складних представлень.
- У продакшн-системах найчастіше використовуються INNER JOIN, LEFT JOIN, та UNION.

---

## 14. Висновки
- JOIN - основний інструмент для об'єднання таблиць.
- INNER JOIN - найпоширеніший тип JOIN-ів, LEFT JOIN - на другому місці, RIGHT JOIN рідкісний та його слід уникати.
- FULL OUTER JOIN - комбінує LEFT JOIN + RIGHT JOIN.
- Операції над множинами дозволяють поєднувати результати запитів як набори рядків.
- Розуміння JOIN є критичним для написання складних практичних SQL-запитів.

## 15. Практична частина лекції

Для демонстрації запитів під час лекції, попередньо було підготовано синтетичні дані, запити знаходяться у [файлі](../../scripts/insert-data.sql).

Під час лекції було розроблено наступні запити:

```sql
-- INNER JOIN
-- вивести список усіх студентів разом з інформацією про їхню групу
select p.first_name || ' ' || p.last_name as "full_name", sg.name
from student s
         inner join student_group sg using(group_id)
         inner join person p using(person_id)
order by sg.name, p.last_name, p.first_name;


-- сформувати список студентів, записаних на курс "бази даних"
-- додати імʼя групи
select p.first_name || ' ' || p.last_name as "student_name", sg.name as "group", c.name as "course"
from course c
         inner join enrolment e using(course_id)
         inner join student s using(student_id)
         inner join student_group sg using(group_id)
         inner join person p using(person_id)
where lower(c.name) = 'бази даних'
order by sg.name, p.last_name, p.first_name;


-- вивести інформацію про кожну групу разом з іменем старости та іменем куратора
select
    sg.name as "group",
    l_p.first_name || ' ' || l_p.last_name as "student_lead",
    curr_p.first_name || ' ' || curr_p.last_name as "student_curator"
from student_group sg
         left join student_lead sl
                   using (group_id)
         left join student_curator sc
                   using (group_id)
         left join student curr
                   on sc.student_id = curr.student_id
         left join student l
                   on sl.student_id = l.student_id
         left join person curr_p
                   on curr.person_id = curr_p.person_id
         left join person l_p
                   on l.person_id = l_p.person_id
where curr.student_id is null
order by sg.name;

-- FULL OUTER JOIN
-- сформувати список кураторів, викладачів без кураторства та груп без куратора

update student_group set curator_id = null where group_id = 1;

select *
from professor prof
         full outer join student_group sg on prof.professor_id = sg.curator_id;

-- UNION + JOIN
-- сформувати список контактів, що містить як професорів, так і студентів
-- для професорів вивести їхню посаду, для студентів — назву групи.

select
    p.first_name || ' ' || p.last_name as "full_name",
    p.phone_number,
    p.email,
    prof.job :: text as "details"
from professor prof
         inner join person p using (person_id)
union
select
    p.first_name || ' ' || p.last_name as "full_name",
    p.phone_number,
    p.email,
    sg.name as "details"
from student s
         inner join person p using (person_id)
         inner join student_group sg using (group_id);
```

Всі запити також можна знайти у [файлі](../../scripts/joins.sql).

## Додаткові матеріали

![Хороша візуалізація JOIN-ів та операцій над множинами](https://i.imgur.com/xLTcOGi.png)

1. [Хороша візуалізація JOIN-ів та операцій над множинами](https://imgur.com/sql-joins-set-operators-xLTcOGi)
2. [Що таке ORM](https://www.freecodecamp.org/news/what-is-an-orm-the-meaning-of-object-relational-mapping-database-tools/)
3. [SQL builder libs vs ORMs](https://www.prisma.io/dataguide/types/relational/comparing-sql-query-builders-and-orms)
