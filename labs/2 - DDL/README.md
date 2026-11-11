# Лабораторна робота №2. Перетворення ER-діаграми на схему PostgreSQL

**Виконав:** Демченко Олександр Стефанович, група ІМ-51  
**Дисципліна:** Бази даних  
**Тема:** Перетворення ER-моделі на реляційну схему PostgreSQL, реалізація DDL-структури та первинне заповнення даними (DML)  

---

## 1. Мета роботи
- Побудувати реляційну схему бази даних на основі ER-моделі, розробленої в Лабораторній роботі №1.
- Написати SQL DDL-інструкції (`CREATE TABLE`) для створення всіх таблиць з відповідними типами даних, первинними (`PRIMARY KEY`) та зовнішніми ключами (`FOREIGN KEY`), а також обмеженнями цілісності (`NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`).
- Реалізувати автоматичну ініціалізацію схеми та тестових даних у Docker-середовищі PostgreSQL.
- Написати SQL DML-інструкції (`INSERT INTO`) для заповнення таблиць якісними тестовими даними (по 3–5 рядків на таблицю).
- Протестувати функціональність схеми у середовищі **pgAdmin 4**.

---

## 2. Опис середовища розгортання (Docker)

Розгортання СУБД та графічного інструменту адміністрування виконано за допомогою **Docker Compose** на основі конфігурації проєкту:

- **СУБД:** PostgreSQL 15 (порт `5432`).
- **Параметри підключення:** Host = `postgres`, Database = `postgres`, User = `postgres`, Password = `password123`.
- **Веб-клієнт:** pgAdmin 4 (доступний за адресою `http://localhost:8080`, логін: `root@kpi.edu`, пароль: `password123`).
- **Ініціалізація:** SQL-скрипт `schema.sql` розміщено в директорії `init-scripts/`, що забезпечує автоматичне створення таблиць та заповнення їх даними при первинному старті контейнера.

---

## 3. Опис реляційної схеми бази даних

Схема складається з 10 таблиць, які повністю відображають предметну область системи реєстрації студентів:

1. **`faculties`** — Факультети (PK: `faculty_id`).
2. **`departments`** — Кафедри (PK: `department_id`, FK: `faculty_id`).
3. **`specialties`** — Спеціальності (PK: `specialty_id`, FK: `faculty_id`).
4. **`academic_groups`** — Навчальні групи (PK: `group_id`, FK: `specialty_id`).
5. **`students`** — Студенти (PK: `student_id`, FK: `group_id`).
6. **`teachers`** — Викладацький склад (PK: `teacher_id`, FK: `department_id`).
7. **`courses`** — Навчальні дисципліни (PK: `course_id`, FK: `department_id`).
8. **`course_assignments`** — Викладацьке навантаження (PK: `assignment_id`, FK: `teacher_id`, `course_id`).
9. **`enrollments`** — Зарахування студентів на курси (PK: `enrollment_id`, FK: `student_id`, `course_id`).
10. **`grade_records`** — Журнал поточного оцінювання (PK: `grade_id`, FK: `student_id`, `course_id`, `teacher_id`).

### Важливі бізнес-обмеження (Constraints):
- **Унікальність email:** `UNIQUE` для студентів та викладачів.
- **Унікальність кодів і назв:** `UNIQUE` для назв факультетів, коду спеціальності та назв академічних груп.
- **Діапазони значень:** 
  - `ects_credits` від 1 до 12 (`CHECK`).
  - `semester` від 1 до 8 (`CHECK`).
  - `final_grade` та `score` від 0 до 100 балів (`CHECK`).
  - `admission_year` та `academic_year` $\ge 2000$ (`CHECK`).
- **Контроль повторних реєстрацій:** Складене обмеження `UNIQUE (student_id, course_id, semester)` у таблиці `enrollments` унеможливлює повторну реєстрацію студента на один і той самий курс у межах одного семестру.
- **Контроль дублювання навантаження:** Складене обмеження `UNIQUE (teacher_id, course_id, academic_year, role_type)` у таблиці `course_assignments`.

---

## 4. SQL-скрипт (DDL та DML)

Нижче наведено повний зміст скрипту `init-scripts/schema.sql`:

```sql
-- ==========================================
-- ЛАБОРАТОРНА РОБОТА №2: DDL та DML Скрипт
-- ==========================================

DROP TABLE IF EXISTS grade_records CASCADE;
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS course_assignments CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS academic_groups CASCADE;
DROP TABLE IF EXISTS specialties CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS faculties CASCADE;

-- ------------------------------------------
-- 1. DDL: СТВОРЕННЯ ТАБЛИЦЬ
-- ------------------------------------------

CREATE TABLE faculties (
    faculty_id      SERIAL PRIMARY KEY,
    faculty_name    VARCHAR(100) NOT NULL UNIQUE,
    building_number VARCHAR(20) NOT NULL
);

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    faculty_id      INTEGER NOT NULL REFERENCES faculties(faculty_id) ON DELETE CASCADE,
    department_name VARCHAR(150) NOT NULL,
    office_building VARCHAR(50) NOT NULL
);

CREATE TABLE specialties (
    specialty_id   SERIAL PRIMARY KEY,
    faculty_id     INTEGER NOT NULL REFERENCES faculties(faculty_id) ON DELETE CASCADE,
    specialty_name VARCHAR(150) NOT NULL,
    specialty_code VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE academic_groups (
    group_id       SERIAL PRIMARY KEY,
    specialty_id   INTEGER NOT NULL REFERENCES specialties(specialty_id) ON DELETE CASCADE,
    group_name     VARCHAR(20) NOT NULL UNIQUE,
    admission_year INTEGER NOT NULL CHECK (admission_year >= 2000)
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    group_id   INTEGER NOT NULL REFERENCES academic_groups(group_id) ON DELETE CASCADE,
    full_name  VARCHAR(120) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE teachers (
    teacher_id    SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id) ON DELETE CASCADE,
    full_name     VARCHAR(120) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    academic_rank VARCHAR(50) NOT NULL DEFAULT 'Lecturer'
);

CREATE TABLE courses (
    course_id     SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id) ON DELETE CASCADE,
    course_name   VARCHAR(150) NOT NULL,
    ects_credits  INTEGER NOT NULL CHECK (ects_credits BETWEEN 1 AND 12)
);

CREATE TABLE course_assignments (
    assignment_id SERIAL PRIMARY KEY,
    teacher_id    INTEGER NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    course_id     INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    academic_year INTEGER NOT NULL CHECK (academic_year >= 2000),
    role_type     VARCHAR(50) NOT NULL,
    CONSTRAINT unique_teacher_course_assignment UNIQUE (teacher_id, course_id, academic_year, role_type)
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id    INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id     INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    semester      INTEGER NOT NULL CHECK (semester BETWEEN 1 AND 8),
    final_grade   INTEGER CHECK (final_grade BETWEEN 0 AND 100),
    status        VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Dropped')),
    CONSTRAINT unique_student_course_semester UNIQUE (student_id, course_id, semester)
);

CREATE TABLE grade_records (
    grade_id    SERIAL PRIMARY KEY,
    student_id  INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id   INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    teacher_id  INTEGER NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    score       INTEGER NOT NULL CHECK (score BETWEEN 0 AND 100),
    work_type   VARCHAR(50) NOT NULL,
    grade_date  DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ------------------------------------------
-- 2. DML: ВСТАВКА ТЕСТОВИХ ДАНИХ
-- ------------------------------------------

INSERT INTO faculties (faculty_name, building_number) VALUES
    ('Факультет інформатики та обчислювальної техніки', 'Корпус 18'),
    ('Факультет прикладної математики', 'Корпус 15'),
    ('Радіотехнічний факультет', 'Корпус 7');

INSERT INTO departments (faculty_id, department_name, office_building) VALUES
    (1, 'Кафедра інформаційного забезпечення', 'Кн. 18, ауд. 401'),
    (1, 'Кафедра системного програмування', 'Кн. 18, ауд. 312'),
    (2, 'Кафедра прикладної математики', 'Кн. 15, ауд. 205');

INSERT INTO specialties (faculty_id, specialty_name, specialty_code) VALUES
    (1, 'Інженерія програмного забезпечення', '121'),
    (1, 'Комп''ютерні науки', '122'),
    (2, 'Прикладна математика', '113');

INSERT INTO academic_groups (specialty_id, group_name, admission_year) VALUES
    (1, 'ІМ-51', 2025),
    (1, 'ІМ-52', 2025),
    (2, 'КН-41', 2024);

INSERT INTO students (group_id, full_name, email) VALUES
    (1, 'Демченко Олександр Стефанович', 'demchenko.o@student.kpi.ua'),
    (1, 'Коваленко Марія Ігорівна', 'kovalenko.m@student.kpi.ua'),
    (1, 'Сидоренко Артем Олегович', 'sydorenko.a@student.kpi.ua'),
    (2, 'Мельник Дмитро Володимирович', 'melnyk.d@student.kpi.ua'),
    (3, 'Ткаченко Софія Василівна', 'tkachenko.s@student.kpi.ua');

INSERT INTO teachers (department_id, full_name, email, academic_rank) VALUES
    (1, 'Петров Петро Петрович', 'petrov.p@kpi.ua', 'Professor'),
    (1, 'Іванов Іван Іванович', 'ivanov.i@kpi.ua', 'Associate Professor'),
    (2, 'Василенко Олена Сергіївна', 'vasylenko.o@kpi.ua', 'Senior Lecturer'),
    (3, 'Шевченко Тарас Григорович', 'shevchenko.t@kpi.ua', 'Lecturer');

INSERT INTO courses (department_id, course_name, ects_credits) VALUES
    (1, 'Бази даних та інформаційні системи', 5),
    (1, 'Об''єктно-орієнтоване програмування', 6),
    (2, 'Операційні системи', 4),
    (3, 'Дискретна математика', 5);

INSERT INTO course_assignments (teacher_id, course_id, academic_year, role_type) VALUES
    (1, 1, 2025, 'Лекції'),
    (2, 1, 2025, 'Лабораторні роботи'),
    (3, 2, 2025, 'Лекції та практики'),
    (4, 4, 2025, 'Лекції');

INSERT INTO enrollments (student_id, course_id, semester, final_grade, status) VALUES
    (1, 1, 2, 95, 'Completed'),
    (1, 2, 2, NULL, 'Active'),
    (2, 1, 2, 88, 'Completed'),
    (3, 1, 2, NULL, 'Active'),
    (4, 3, 4, 75, 'Completed');

INSERT INTO grade_records (student_id, course_id, teacher_id, score, work_type, grade_date) VALUES
    (1, 1, 2, 100, 'Лабораторна робота №1', '2026-03-01'),
    (1, 1, 2, 90, 'Лабораторна робота №2', '2026-03-15'),
    (1, 1, 1, 95, 'Модульна контрольна робота', '2026-04-01'),
    (2, 1, 2, 85, 'Лабораторна робота №1', '2026-03-01'),
    (3, 1, 2, 70, 'Лабораторна робота №1', '2026-03-01');
```

---

## 6. Висновки

У ході виконання лабораторної роботи №2 було успішно перетворено концептуальну ER-модель на фізичну реляційну схему в СУБД **PostgreSQL**.

### Досягнуті результати:
1. Реалізовано повний DDL-скрипт з урахуванням типів даних, первинних ключів, зовнішніх ключів та обмежень цілісності (`CHECK`, `UNIQUE`, `NOT NULL`, `DEFAULT`).
2. Організовано автоматичний запуск СУБД та ініціалізацію бази даних через **Docker Compose** та каталог `init-scripts/`.
3. Наповнено базу даних зв'язаними тестовими даними (DML) без порушень обмежень цілісності.
4. Успішно протестовано працездатність схеми та виконання запитів за допомогою інструменту **pgAdmin 4**.
