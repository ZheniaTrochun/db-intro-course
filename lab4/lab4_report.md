# Звіт до лабораторної роботи №4

## Тема роботи

Агрегація даних, групування, фільтрування груп, об'єднання таблиць і підзапити в PostgreSQL.

## Мета роботи

Навчитися створювати аналітичні SQL-запити з використанням агрегатних функцій, `GROUP BY`, `HAVING`, різних типів `JOIN` і підзапитів.

## 1. Агрегатні запити

### 1.1. Загальна кількість користувачів

```sql
SELECT COUNT(*) AS total_users
FROM users;
```

`COUNT(*)` рахує кількість усіх рядків у таблиці `users`. Запит потрібен для отримання загальної кількості користувачів системи.

### 1.2. Середня, мінімальна та максимальна оцінки

```sql
SELECT
    ROUND(AVG(grade)) AS average_grade,
    MIN(grade) AS minimum_grade,
    MAX(grade) AS maximum_grade
FROM enrollments
WHERE grade IS NOT NULL;
```

Запит аналізує оцінки студентів:

- `AVG(grade)` обчислює середню оцінку;
- `MIN(grade)` знаходить найменшу оцінку;
- `MAX(grade)` знаходить найбільшу оцінку;
- `ROUND` округлює середню оцінку.

Умова `grade IS NOT NULL` виключає записи, у яких оцінка ще не виставлена.

### 1.3. Кількість користувачів у кожному гуртожитку

```sql
SELECT d.dorm_number, COUNT(u.user_id) AS users_count
FROM dorms d
LEFT JOIN users u ON u.dorm_id = d.dorm_id
GROUP BY d.dorm_number
ORDER BY d.dorm_number;
```

Запит групує користувачів за гуртожитками та рахує їх кількість у кожній групі. `LEFT JOIN` зберігає у результаті навіть гуртожитки, у яких немає користувачів. `GROUP BY` формує окрему групу для кожного номера гуртожитку.

### 1.4. Кількість зайнятих паркомісць

```sql
SELECT d.dorm_number,
       SUM(CASE WHEN p.user_id IS NOT NULL THEN 1 ELSE 0 END) AS occupied_slots
FROM dorms d
LEFT JOIN parking_slots p ON p.dorm_id = d.dorm_id
GROUP BY d.dorm_id, d.dorm_number
HAVING SUM(CASE WHEN p.user_id IS NOT NULL THEN 1 ELSE 0 END) > 0
ORDER BY d.dorm_number;
```

Вираз `CASE` перетворює кожне зайняте паркомісце на `1`, а вільне — на `0`. Функція `SUM` підраховує зайняті місця для кожного гуртожитку. `HAVING` залишає тільки ті гуртожитки, де є хоча б одне зайняте місце.

## 2. Запити з різними типами JOIN

У скрипті вже були запити з `INNER JOIN` і `LEFT JOIN`. Нижче наведено додатковий тип об'єднання, тому загалом використано щонайменше три різні типи `JOIN`.

### 2.1. `RIGHT JOIN`: гуртожитки та їхні паркомісця

```sql
SELECT d.dorm_number, p.slot_number, p.user_id
FROM parking_slots p
RIGHT JOIN dorms d ON d.dorm_id = p.dorm_id
ORDER BY d.dorm_number, p.slot_number;
```

`RIGHT JOIN` гарантує, що у результаті будуть усі гуртожитки, навіть якщо для певного гуртожитку немає паркомісця. Якщо відповідного запису в `parking_slots` немає, значення `slot_number` і `user_id` буде `NULL`.

### 2.2. `INNER JOIN`

```sql
SELECT s.student_id, u.first_name, u.last_name,
       d.dorm_number, r.room_number, s.status
FROM students s
JOIN users u ON u.user_id = s.user_id
JOIN dorms d ON d.dorm_id = u.dorm_id
JOIN rooms r ON r.room_id = s.room_id
ORDER BY d.dorm_number, r.room_number;
```

Цей запит поєднує студентів, користувачів, гуртожитки та кімнати. `INNER JOIN` повертає тільки ті записи, для яких існують відповідні рядки в усіх пов'язаних таблицях. Тому до результату потрапляють студенти, які мають призначені гуртожиток і кімнату.

### 2.3. `LEFT JOIN`

```sql
SELECT u.user_id, u.first_name, u.last_name,
       u.email, d.dorm_number
FROM users u
LEFT JOIN dorms d ON d.dorm_id = u.dorm_id
WHERE u.status = 'active'
ORDER BY u.user_id;
```

Запит показує активних користувачів і їхні гуртожитки. На відміну від `INNER JOIN`, `LEFT JOIN` не виключає користувача, якщо йому ще не призначено гуртожиток. У такому випадку `dorm_number` буде `NULL`.

### 2.4. `RIGHT JOIN`

```sql
SELECT d.dorm_number, p.slot_number, p.user_id
FROM parking_slots p
RIGHT JOIN dorms d ON d.dorm_id = p.dorm_id
ORDER BY d.dorm_number, p.slot_number;
```

`RIGHT JOIN` виводить повний список усіх гуртожитків, а також показує номери існуючих паркомісць та ID користувачів які їх займають.

## 3. Підзапити

### 3.1. Підзапит у `SELECT`

```sql
SELECT dep.department_name,
       (SELECT COUNT(*)
        FROM courses c
        WHERE c.department_id = dep.department_id) AS courses_count
FROM departments dep
ORDER BY dep.department_name;
```

Основний запит перебирає кафедри. Для кожної кафедри внутрішній запит рахує кількість курсів із таким самим `department_id`. Це корельований підзапит, оскільки він використовує значення `dep.department_id` із зовнішнього запиту.

### 3.2. Підзапит у `WHERE`

```sql
SELECT c.course_title
FROM courses c
WHERE c.course_id IN (
    SELECT e.course_id
    FROM enrollments e
    GROUP BY e.course_id
    HAVING COUNT(*) > 1
)
ORDER BY c.course_title;
```

Внутрішній запит групує записи в `enrollments` за курсами та залишає тільки ті курси, на які записано більше одного студента. Зовнішній запит через `IN` виводить назви цих курсів.

### 3.3. Підзапит у `HAVING`

```sql
SELECT dep.department_name, COUNT(c.course_id) AS courses_count
FROM departments dep
LEFT JOIN courses c ON c.department_id = dep.department_id
GROUP BY dep.department_id, dep.department_name
HAVING COUNT(c.course_id) >= (
    SELECT AVG(course_count)
    FROM (
        SELECT COUNT(*) AS course_count
        FROM courses
        GROUP BY department_id
    ) AS department_course_counts
)
ORDER BY dep.department_name;
```

Спочатку внутрішній запит рахує кількість курсів для кожної кафедри. Потім функція `AVG` обчислює середню кількість курсів. Зовнішній запит залишає тільки ті кафедри, у яких кількість курсів не менша за середнє значення.

Оскільки умова перевіряє результат агрегатної функції `COUNT`, використовується `HAVING`, а не `WHERE`.

## 4. Висновок

У лабораторній роботі було створено аналітичні запити для бази даних студентського містечка. Використано агрегатні функції `COUNT`, `SUM`, `AVG`, `MIN` і `MAX`, групування через `GROUP BY`, фільтрування груп через `HAVING`, різні типи об'єднань `INNER JOIN`, `LEFT JOIN` і `RIGHT JOIN`, а також підзапити в `SELECT`, `WHERE` та `HAVING`.

