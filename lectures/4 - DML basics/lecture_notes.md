# Конспект лекції - SQL частина 1 - CRUD операції

## 1. SQL як стандарт
- SQL (Structured Query Language) - це не конкретна мова програмування, а стандарт для роботи з базами даних.
- Різні системи управління базами даних (СУБД) імплементують цей стандарт по-своєму.
- Існують відмінності у синтаксисі та можливостях між різними СУБД. Запит, який успішно виконується в PostgreSQL, може не працювати в MySQL.
- SQL має багато версій стандарту, більшість СУБД підтримують стандарт SQL-92 та частково новіші стандарти.

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
- Можна вставляти кілька рядків одразу:
  ```sql
  INSERT INTO student (name, surname, contact_data_id, group_id)
  VALUES 
    ('Андрій', 'Ковальчук', 1, 1),
    ('Марія', 'Коваленко', 2, 2),
    ('Олександр', 'Шевченко', 3, 3);
  ```
- Колонки з DEFAULT значеннями можна пропустити.
- Колонки з автоінкрементом (SERIAL, IDENTITY) зазвичай не вказуються.

---

## 3. SELECT
```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Основні елементи SELECT:
- `*` - вибір усіх колонок (не рекомендується для production-коду).
- `AS` - використання псевдонімів для колонок і таблиць:
  ```sql
  SELECT 
    name || ' ' || surname AS full_name
  FROM student
  WHERE name = 'Андрій' AND surname = 'Ковальчук';
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
- Оператори порівняння: `=, >, <, >=, <=, <>, !=`
- Діапазони: `BETWEEN value1 AND value2`
- Списки: `IN (value1, value2, ...)`
- Шаблони: `LIKE 'pattern'`
  - Рядкові порівняння - чутливі до регістру.
  - Для нечутливого пошуку використовуються функції (`LOWER`, `UPPER`) або специфічні оператори (наприклад, `ILIKE` у PostgreSQL).
  - Шаблони:
      - `%` - будь-яка кількість символів.
      - `_` - рівно один символ.
- Логічні оператори: `AND`, `OR`, `NOT`
- Перевірка NULL: `IS NULL`, `IS NOT NULL`

### Сортування:  
```sql
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC] [NULLS FIRST|LAST]
```

### Функції агрегації
- `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.
- Агрегують дані та повертають лише один рядок.  

Приклад:
```sql
SELECT COUNT(*) FROM student;
SELECT COUNT(DISTINCT group_id) FROM student;
```

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
    name = 'Андрій',
    surname = 'Ковальчук',
    contact_data_id = 1,
    group_id = 102
  WHERE student_id = 1;
  ```

### Безпечні практики:
- Спочатку перевірте, які рядки будуть оновлені, за допомогою SELECT

---

## 5. DELETE
```sql
DELETE FROM table_name
WHERE condition;
```

### Основні особливості DELETE:
- Якщо не вказати `WHERE` - видаляються **усі рядки** таблиці.
- DELETE видаляє рядки, але не скидає лічильники автоінкременту.

### TRUNCATE - швидке видалення всіх даних:
```sql
TRUNCATE TABLE student;
```
- Видаляє всі рядки з таблиці
- Працює швидше, ніж `DELETE` без `WHERE`
- Скидає лічильники автоінкременту (в більшості СУБД)
- Не завжди підтримує `ROLLBACK` (залежить від СУБД)

### Безпечні практики:
- Спочатку перевірте, які рядки будуть видалені, за допомогою SELECT
- Розгляньте можливість використання "м'якого видалення" (soft delete) замість фізичного:
  ```sql
  -- Припустимо, що ми додали колонку is_deleted до таблиці student
  UPDATE student SET is_deleted = TRUE WHERE name = 'Андрій' AND surname = 'Ковальчук';
  ```

---

## 6. Практична частина лекції

Для демонстрації запитів підчас лекції, попередньо було підготовано синтетичні дані, запити знаходяться у [файлі](../../scripts/insert-data.sql).

Підчас лекції було розроблено наступні запити:

```sql
-- додати лектора
INSERT INTO contact_data(email, phone)
VALUES ('trochun.yevhenii@lll.kpi.ua', '380661769967');

SELECT * FROM contact_data WHERE phone = '380661769967';

INSERT INTO teacher(name, surname, contact_data_id, qualification)
VALUES ('Євгеній', 'Трочун', 21, 'доктор філософії');

SELECT * FROM teacher WHERE surname = 'Трочун';

-- додати курс "Бази даних"
INSERT INTO course(name, credits, student_year, is_active, teacher_id)
VALUES ('Бази даних', 5, 2, TRUE, 11);

SELECT * FROM course WHERE name = 'Бази даних';

-- записати студента на курс
INSERT INTO enrolment (course_id, student_id)
VALUES (13, 1),
(13, 5),
(13, 10);

SELECT * FROM enrolment WHERE course_id = 13;

-- знайти всіх студентів 121 спеціальності
SELECT * FROM student WHERE profession = 121;

-- знайти всіх студентів БЕЗ спеціальності
SELECT * FROM student WHERE profession IS NULL;

-- знайти всі курси, що викладаються на 2-му році навчання
-- знайти всі не активні курси
SELECT * FROM course WHERE NOT is_active;

-- знайти всі грути потоку ІТ-1Х
SELECT * FROM student_group;
SELECT * FROM student_group WHERE name = 'ІТ-1%';

-- знайти всіх викладачів, у кого рівень кваліфікації нижчий доктора філософії
SELECT * FROM teacher WHERE qualification NOT IN ('доктор філософії', 'доктор наук') OR qualification IS NULL;

-- порахувати середній бал студентів хто успішно здав сесію
SELECT AVG(grade) FROM enrolment WHERE grade > 60;

-- порахувати який відсоток студентів не склав сесію
SELECT
    count(distinct student_id) FILTER (WHERE grade is null OR grade < 60) as failed_students_count,
    count(distinct student_id) as total_students_count,
    (
        count(distinct student_id) FILTER (WHERE grade is null OR grade < 60) /
		count(distinct student_id)::real
        ) * 100 as failed_percent
FROM enrolment;

-- перевести студентів з МА-92 до ПС-91
SELECT * from student_group where NAME in ('МА-92', 'ПС-91');
select * from student where group_id = 3;
update student set group_id = 7 WHERE group_id = 3;

-- деактивувати курс комп мереж
select * from course;
update course set is_active = FALSE where course_id = 10;

-- видалити курс з кібербезпеки
select * from course;
delete from course where course_id = 12;
```

Всі запити також можна знайти у [файлі](../../scripts/crud.sql).

---

## 6. Висновки
- SQL забезпечує стандартний спосіб роботи з даними.
- Різні СУБД імплементують деякі частини стандарту SQL по-різному.
- Основна робота з базою даних - це написання запитів (`SELECT` займає до 70–80% практичної роботи).
- Важливо перевіряти результати перед виконанням операцій, що змінюють дані (`UPDATE`, `DELETE`).

### 7. Додаткові ресурси:
- [Mode Analytics SQL Tutorial](https://mode.com/sql-tutorial/)
- [SQLZoo - Interactive SQL Exercises](https://sqlzoo.net/)
