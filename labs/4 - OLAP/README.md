# Звіт до Лабораторної роботи №4: Аналітичні SQL-запити (OLAP)

**Мета роботи:** Навчитися створювати аналітичні SQL-запити для агрегації, групування, фільтрації та об'єднання даних із кількох таблиць у PostgreSQL.

---

## 1. Агрегатні функції та групування (`COUNT`, `AVG`, `SUM`, `MIN`, `MAX`, `GROUP BY`)

### 1.1 Загальна кількість студентів та роки вступу
* **SQL-запит:**
```sql
SELECT 
    COUNT(*) AS total_students,
    MIN(admission_year) AS earliest_admission,
    MAX(admission_year) AS latest_admission
FROM academic_groups g
JOIN students s ON g.group_id = s.group_id;
```
* **Що робить:** Об'єднує таблиці студентів і навчальних груп, підраховує загальну кількість студентів (`COUNT`) та визначає найраніший (`MIN`) і найпізніший (`MAX`) роки їхнього вступу.

### 1.2 Середній підсумковий бал за семестрами
* **SQL-запит:**
```sql
SELECT 
    semester,
    COUNT(enrollment_id) AS completed_courses_count,
    ROUND(AVG(final_grade), 2) AS avg_final_grade
FROM enrollments
WHERE status = 'Completed'
GROUP BY semester;
```
* **Що робить:** Відбирає лише завершені курси (`status = 'Completed'`), групує їх за семестрами та обчислює кількість закритих дисциплін і середню оцінку (`AVG`), округлену до двох знаків після коми.

### 1.3 Загальний обсяг кредитів ECTS за кафедрами
* **SQL-запит:**
```sql
SELECT 
    department_id,
    COUNT(course_id) AS total_courses,
    SUM(ects_credits) AS total_ects_credits
FROM courses
GROUP BY department_id;
```
* **Що робить:** Групує дисципліни за ідентифікатором кафедри (`department_id`), підраховує кількість курсів на кожній кафедрі та знаходить їхню сумарну кількість кредитів (`SUM`).

### 1.4 Аналіз поточних оцінок за типом роботи
* **SQL-запит:**
```sql
SELECT 
    work_type,
    COUNT(grade_id) AS grades_count,
    ROUND(AVG(score), 2) AS avg_score,
    MIN(score) AS min_score,
    MAX(score) AS max_score
FROM grade_records
GROUP BY work_type;
```
* **Що робить:** Групує записи журналу оцінок за типом роботи (`work_type`) і для кожного виду контролю виводить кількість оцінок, середній, мінімальний та максимальний бали.

---

## 2. Фільтрація згрупованих даних (`HAVING`)

### 2.1 Популярні курси з активними або завершеними зарахуваннями
* **SQL-запит:**
```sql
SELECT 
    course_id,
    COUNT(student_id) AS active_enrolled_students
FROM enrollments
WHERE status IN ('Active', 'Completed')
GROUP BY course_id
HAVING COUNT(student_id) > 1;
```
* **Що робить:** Спочатку відбирає зарахування зі статусами `'Active'` або `'Completed'`, групує їх за курсами (`course_id`), а потім за допомогою `HAVING` залишає лише ті дисципліни, на яких навчається більше одного студента.

---

## 3. Об'єднання таблиць (`INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`)

### 3.1 `INNER JOIN`: Студенти та назви їхніх груп
* **SQL-запит:**
```sql
SELECT 
    s.full_name AS student_name,
    g.group_name
FROM students s
JOIN academic_groups g ON s.group_id = g.group_id;
```
* **Що робить:** Повертає ПІБ студентів та назви їхніх груп, виводячи тільки ті записи, де є точний збіг між таблицями `students` та `academic_groups`.

### 3.2 `INNER JOIN`: Викладачі та їхні кафедри
* **SQL-запит:**
```sql
SELECT 
    t.full_name AS teacher_name,
    d.department_name
FROM teachers t
JOIN departments d ON t.department_id = d.department_id;
```
* **Що робить:** Об'єднує таблиці викладачів і кафедр за `department_id`, показуючи, на якій кафедрі працює кожен викладач.

### 3.3 `LEFT JOIN`: Усі студенти та їхні зарахування на курси
* **SQL-запит:**
```sql
SELECT 
    s.full_name AS student_name,
    e.course_id,
    e.status
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id;
```
* **Що робить:** Виводить абсолютно всіх студентів із таблиці `students`. Якщо студент ще не записаний на жоден курс, він усе одно потрапляє у вибірку зі значеннями `NULL` у полях курсу та статусу.

### 3.4 `LEFT JOIN`: Усі дисципліни та призначені викладачі
* **SQL-запит:**
```sql
SELECT 
    c.course_name,
    ca.teacher_id,
    ca.role_type
FROM courses c
LEFT JOIN course_assignments ca ON c.course_id = ca.course_id;
```
* **Що робить:** Відображає всі наявні курси, включно з тими, на які ще не призначено викладачів (для них поля `teacher_id` та `role_type` містять `NULL`).

### 3.5 `RIGHT JOIN`: Усі кафедри та викладачі на них
* **SQL-запит:**
```sql
SELECT 
    t.full_name AS teacher_name,
    d.department_name
FROM teachers t
RIGHT JOIN departments d ON t.department_id = d.department_id;
```
* **Що робить:** Гарантує виведення всіх кафедр із правої таблиці `departments`, навіть якщо на якійсь кафедрі ще немає жодного закріпленого викладача (`teacher_name = NULL`).

### 3.6 `RIGHT JOIN`: Усі факультети та спеціальності
* **SQL-запит:**
```sql
SELECT 
    sp.specialty_name,
    f.faculty_name
FROM specialties sp
RIGHT JOIN faculties f ON sp.faculty_id = f.faculty_id;
```
* **Що робить:** Виводить усі факультети з таблиці `faculties` та прив'язані до них спеціальності, зберігаючи в результаті навіть порожні факультети без спеціальностей.

---

## 4. Використання підзапитів (`Subqueries`)

### 4.1 Підзапит у `WHERE`: Курси з кредитами вище середнього
* **SQL-запит:**
```sql
SELECT 
    course_name,
    ects_credits
FROM courses
WHERE ects_credits > (
    SELECT AVG(ects_credits) 
    FROM courses
);
```
* **Що робить:** Внутрішній запит обчислює середню кількість кредитів ECTS по всіх дисциплінах, а зовнішній — виводить лише ті курси, обсяг кредитів яких перевищує це середнє значення.

### 4.2 Підзапит у `SELECT`: Кількість викладачів на кожній кафедрі
* **SQL-запит:**
```sql
SELECT 
    d.department_name,
    (
        SELECT COUNT(*) 
        FROM teachers t 
        WHERE t.department_id = d.department_id
    ) AS teachers_count
FROM departments d;
```
* **Що робить:** Для кожної кафедри з таблиці `departments` виконує корельований підзапит у `SELECT`, який підраховує кількість викладачів, прикріплених до цієї кафедри.