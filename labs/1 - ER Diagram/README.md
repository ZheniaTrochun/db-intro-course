# Лабораторна робота №1. Збір вимог та розробка схеми ER

**Виконав:** Демченко Олександр Стефанович, група ІМ-51  
**Тема:** Система реєстрації студентів та навчального процесу  

---

## 1. Завдання та мета
- Зібрати та систематизувати предметні вимоги до системи.
- Визначити сутності, їхні атрибути, типи даних, первинні та зовнішні ключі.
- Систематизувати зв'язки між сутностями та бізнес-правила (обмеження).
- Побудувати повноцінну ER-модель, готову до прямої трансляції в DDL SQL для PostgreSQL.

---

## 2. Вимоги до системи

Автоматизована система реєстрації студентів призначена для обліку суб'єктів навчального процесу, каталогізації курсів, обробки реєстрацій студентів на дисципліни, проміжного та підсумкового оцінювання, а також автоматичного контролю цілісності даних.

### Функціональні вимоги:
1. **Управління оргструктурою:** Облік факультетів, кафедр, спеціальностей та навчальних груп.
2. **Управління суб'єктами:** Облік персональних даних студентів та викладацького складу.
3. **Каталог дисциплін та навантаження:** Навчальні курси закріплюються за кафедрами, а викладачі призначаються на відповідні дисципліни з вказуванням типу занять (лекції, лабораторні).
4. **Реєстрація та оцінювання:** 
   - Фіксація зарахування студентів на курси по семестрах з обчисленням підсумкового балу.
   - Журнал поточних оцінок для проміжного контролю (лабораторні, модулі, іспити).

### Системні вимоги та обмеження:
- **Унікальність:** Запобігання дублюванню e-mail, кодів спеціальностей та назв груп.
- **Целісність посилань:** Використання зовнішніх ключів (Foreign Keys) для забезпечення цілісності зв'язків.
- **Валідація балів та кредитів:** Обмеження діапазонів значений для оцінок, семестрів та ECTS.
- **Контроль дублікатів:** Заборона повторного зарахування студента на один і той самий курс у межах одного семестру.

---

## 3. Опис сутностей та атрибутів

- **Факультет (`Faculty`)**:
  - `INTEGER` | `faculty_id` | **PK**, AUTOINCREMENT — Унікальний ID факультету
  - `VARCHAR(100)` | `faculty_name` | **UNIQUE**, **NOT NULL** — Назва факультету
  - `VARCHAR(20)` | `building_number` | **NOT NULL** — Номер корпусу

- **Кафедра (`Department`)**:
  - `INTEGER` | `department_id` | **PK**, AUTOINCREMENT — Унікальний ID кафедр
  - `INTEGER` | `faculty_id` | **FK** (`Faculty.faculty_id`), **NOT NULL** — Факультет
  - `VARCHAR(150)` | `department_name` | **NOT NULL** — Назва кафедри
  - `VARCHAR(50)` | `office_building` | **NOT NULL** — Кабінет / корпус

- **Спеціальність (`Specialty`)**:
  - `INTEGER` | `specialty_id` | **PK**, AUTOINCREMENT — Унікальний ID спеціальності
  - `INTEGER` | `faculty_id` | **FK** (`Faculty.faculty_id`), **NOT NULL** — Факультет
  - `VARCHAR(150)` | `specialty_name` | **NOT NULL** — Назва спеціальності
  - `VARCHAR(20)` | `specialty_code` | **UNIQUE**, **NOT NULL** — Шифр спеціальності (напр. "121")

- **Навчальна група (`AcademicGroup`)**:
  - `INTEGER` | `group_id` | **PK**, AUTOINCREMENT — Унікальний ID групи
  - `INTEGER` | `specialty_id` | **FK** (`Specialty.specialty_id`), **NOT NULL** — Спеціальність
  - `VARCHAR(20)` | `group_name` | **UNIQUE**, **NOT NULL** — Назва групи (напр. "ІМ-51")
  - `INTEGER` | `admission_year` | **NOT NULL**, `CHECK (admission_year >= 2000)` — Рік вступу

- **Студент (`Student`)**:
  - `INTEGER` | `student_id` | **PK**, AUTOINCREMENT — Унікальний ID студента
  - `INTEGER` | `group_id` | **FK** (`AcademicGroup.group_id`), **NOT NULL** — Навчальна група
  - `VARCHAR(120)` | `full_name` | **NOT NULL** — ПІБ студента
  - `VARCHAR(100)` | `email` | **UNIQUE**, **NOT NULL** — Корпоративний e-mail

- **Викладач (`Teacher`)**:
  - `INTEGER` | `teacher_id` | **PK**, AUTOINCREMENT — Унікальний ID викладача
  - `INTEGER` | `department_id` | **FK** (`Department.department_id`), **NOT NULL** — Кафедра
  - `VARCHAR(120)` | `full_name` | **NOT NULL** — ПІБ викладача
  - `VARCHAR(100)` | `email` | **UNIQUE**, **NOT NULL** — Корпоративний e-mail
  - `VARCHAR(50)` | `academic_rank` | `DEFAULT 'Lecturer'` — Вчене звання / посада

- **Курс / Дисципліна (`Course`)**:
  - `INTEGER` | `course_id` | **PK**, AUTOINCREMENT — Унікальний ID курсу
  - `INTEGER` | `department_id` | **FK** (`Department.department_id`), **NOT NULL** — Відповідальна кафедра
  - `VARCHAR(150)` | `course_name` | **NOT NULL** — Назва дисципліни
  - `INTEGER` | `ects_credits` | **NOT NULL**, `CHECK (ects_credits BETWEEN 1 AND 12)` — Кредити ECTS

- **Викладацьке навантаження (`CourseAssignment`)** *(асоціативна сутність Викладач — Курс)*:
  - `INTEGER` | `assignment_id` | **PK**, AUTOINCREMENT — Унікальний ID призначення
  - `INTEGER` | `teacher_id` | **FK** (`Teacher.teacher_id`), **NOT NULL** — Викладач
  - `INTEGER` | `course_id` | **FK** (`Course.course_id`), **NOT NULL** — Курс
  - `INTEGER` | `academic_year` | **NOT NULL**, `CHECK (academic_year >= 2000)` — Навчальний рік
  - `VARCHAR(50)` | `role_type` | **NOT NULL** — Тип занять (Лекції, Лабораторні, Практика)

- **Реєстрація на курс (`Enrollment`)** *(асоціативна сутність Студент — Курс)*:
  - `INTEGER` | `enrollment_id` | **PK**, AUTOINCREMENT — Унікальний ID реєстрації
  - `INTEGER` | `student_id` | **FK** (`Student.student_id`), **NOT NULL** — Студент
  - `INTEGER` | `course_id` | **FK** (`Course.course_id`), **NOT NULL** — Курс
  - `INTEGER` | `semester` | **NOT NULL**, `CHECK (semester BETWEEN 1 AND 8)` — Номер семестру
  - `INTEGER` | `final_grade` | `NULLABLE`, `CHECK (final_grade BETWEEN 0 AND 100)` — Підсумкова оцінка
  - `VARCHAR(20)` | `status` | `DEFAULT 'Active'` — Статус (`Active`, `Completed`, `Dropped`)

- **Журнал оцінок (`GradeRecord`)**:
  - `INTEGER` | `grade_id` | **PK**, AUTOINCREMENT — Унікальний ID оцінки
  - `INTEGER` | `student_id` | **FK** (`Student.student_id`), **NOT NULL** — Студент
  - `INTEGER` | `course_id` | **FK** (`Course.course_id`), **NOT NULL** — Курс
  - `INTEGER` | `teacher_id` | **FK** (`Teacher.teacher_id`), **NOT NULL** — Викладач, що виставив бал
  - `INTEGER` | `score` | **NOT NULL**, `CHECK (score BETWEEN 0 AND 100)` — Оцінка за роботу
  - `VARCHAR(50)` | `work_type` | **NOT NULL** — Тип роботи (Лабораторна №1, Модуль, Екзамен)
  - `DATE` | `grade_date` | **NOT NULL**, `DEFAULT CURRENT_DATE` — Дата виставлення

---

## 4. Зв'язки між сутностями

- **`Faculty — Department` (1 : N):** Один факультет містить декілька кафедр.
- **`Faculty — Specialty` (1 : N):** Один факультет пропонує декілька спеціальностей.
- **`Specialty — AcademicGroup` (1 : N):** На спеціальності формується декілька академічних груп.
- **`AcademicGroup — Student` (1 : N):** У групі навчається декілька студентів; кожен студент закріплений строго за однією групою.
- **`Department — Teacher` (1 : N):** На кафедрі працює декілька викладачів.
- **`Department — Course` (1 : N):** Кафедра забезпечує викладання відповідних дисциплін.
- **`Teacher — CourseAssignment — Course` (N : M):** Один курс можуть викладати кілька викладачів (наприклад, лекції та лабораторні), а один викладач може вести кілька курсів.
- **`Student — Enrollment — Course` (N : M):** Студент зараховується на декілька курсів, а курс включає багатьох студентів.
- **`GradeRecord` (Зв'язок 1:N з Student, Course, Teacher):** Кожна оцінка у журналі прив'язана до конкретного студента, дисципліни та викладача, який її виставив.

---

## 5. Обмеження та бізнес-правила:

1. **Правило унікальності бізнес-ідентифікаторів:**
   - E-mail студентів та викладачів мають бути унікальними (`UNIQUE`).
   - Назва факультету (`faculty_name`), код спеціальності (`specialty_code`) та назва групи (`group_name`) є строго унікальними в межах всієї БД.
2. **Валідація балів та числових показників:**
   - `ects_credits`: від `1` до `12`.
   - `semester`: від `1` до `8`.
   - `final_grade` та `score`: від `0` до `100`.
   - `admission_year` та `academic_year`: не менше `2000`.
3. **Запобігання дублюванню реєстрацій:**
   - Комбінація `(student_id, course_id, semester)` у таблиці `Enrollment` має обмеження **UNIQUE**. Студент не може бути зареєстрований на той самий курс двічі в одному семестрі.
4. **Запобігання дублюванню викладацького навантаження:**
   - Комбінація `(teacher_id, course_id, academic_year, role_type)` має обмеження **UNIQUE** у таблиці `CourseAssignment`.

---

## 6. ER діаграма (Mermaid)

```mermaid
erDiagram
    FACULTY ||--|{ DEPARTMENT : "has"
    FACULTY ||--|{ SPECIALTY : "offers"
    SPECIALTY ||--|{ ACADEMIC_GROUP : "belongs_to"
    ACADEMIC_GROUP ||--o{ STUDENT : "contains"
    DEPARTMENT ||--|{ TEACHER : "employs"
    DEPARTMENT ||--|{ COURSE : "provides"
    
    TEACHER ||--o{ COURSE_ASSIGNMENT : "assigned_to"
    COURSE ||--o{ COURSE_ASSIGNMENT : "taught_in"

    STUDENT ||--o{ ENROLLMENT : "registers"
    COURSE ||--o{ ENROLLMENT : "has_students"

    STUDENT ||--o{ GRADE_RECORD : "receives"
    COURSE ||--o{ GRADE_RECORD : "evaluated_for"
    TEACHER ||--o{ GRADE_RECORD : "grades"

    FACULTY {
        int faculty_id PK
        varchar faculty_name UK
        varchar building_number
    }

    DEPARTMENT {
        int department_id PK
        int faculty_id FK
        varchar department_name
        varchar office_building
    }

    SPECIALTY {
        int specialty_id PK
        int faculty_id FK
        varchar specialty_name
        varchar specialty_code UK
    }

    ACADEMIC_GROUP {
        int group_id PK
        int specialty_id FK
        varchar group_name UK
        int admission_year
    }

    STUDENT {
        int student_id PK
        int group_id FK
        varchar full_name
        varchar email UK
    }

    TEACHER {
        int teacher_id PK
        int department_id FK
        varchar full_name
        varchar email UK
        varchar academic_rank
    }

    COURSE {
        int course_id PK
        int department_id FK
        varchar course_name
        int ects_credits
    }

    COURSE_ASSIGNMENT {
        int assignment_id PK
        int teacher_id FK
        int course_id FK
        int academic_year
        varchar role_type
    }

    ENROLLMENT {
        int enrollment_id PK
        int student_id FK
        int course_id FK
        int semester
        int final_grade
        varchar status
    }

    GRADE_RECORD {
        int grade_id PK
        int student_id FK
        int course_id FK
        int teacher_id FK
        int score
        varchar work_type
        date grade_date
    }
