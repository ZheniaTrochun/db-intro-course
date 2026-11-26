-- ===================================================
-- ЛАБОРАТОРНА РОБОТА №5: Нормалізована схема БД (3НФ)
-- ===================================================

-- Очищення всіх таблиць (у зворотному порядку залежностей)
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

-- Нові таблиці-довідники (3НФ)
DROP TABLE IF EXISTS work_types CASCADE;
DROP TABLE IF EXISTS assignment_roles CASCADE;
DROP TABLE IF EXISTS academic_ranks CASCADE;

-- =============================================================
-- СТВОРЕННЯ ТАБЛИЦЬ-ДОВІДНИКІВ (Усунення транзитивних ФЗ - 3НФ)
-- =============================================================

CREATE TABLE academic_ranks (
    rank_id   SERIAL PRIMARY KEY,
    rank_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE assignment_roles (
    role_id   SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE work_types (
    work_type_id   SERIAL PRIMARY KEY,
    work_type_name VARCHAR(100) NOT NULL UNIQUE,
    max_score      INTEGER NOT NULL DEFAULT 100 CHECK (max_score > 0 AND max_score <= 100)
);

-- ==========================================================
-- 3. СТВОРЕННЯ ОСНОВНИХ ТАБЛИЦЬ У 3НФ
-- ==========================================================

CREATE TABLE faculties (
    faculty_id      SERIAL PRIMARY KEY,
    faculty_name    VARCHAR(100) NOT NULL UNIQUE,
    building_number VARCHAR(20) NOT NULL
);

-- 1НФ: office_building розділено на building_number та room_number
CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    faculty_id      INTEGER NOT NULL REFERENCES faculties(faculty_id) ON DELETE RESTRICT,
    department_name VARCHAR(150) NOT NULL,
    building_number VARCHAR(20) NOT NULL,
    room_number     VARCHAR(20) NOT NULL
);

CREATE TABLE specialties (
    specialty_id   SERIAL PRIMARY KEY,
    faculty_id     INTEGER NOT NULL REFERENCES faculties(faculty_id) ON DELETE RESTRICT,
    specialty_name VARCHAR(150) NOT NULL,
    specialty_code VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE academic_groups (
    group_id       SERIAL PRIMARY KEY,
    specialty_id   INTEGER NOT NULL REFERENCES specialties(specialty_id) ON DELETE RESTRICT,
    group_name     VARCHAR(20) NOT NULL UNIQUE,
    admission_year INTEGER NOT NULL CHECK (admission_year >= 2000)
);

-- 1НФ: full_name розбито на атомарні атрибути (last_name, first_name, middle_name)
CREATE TABLE students (
    student_id  SERIAL PRIMARY KEY,
    group_id    INTEGER NOT NULL REFERENCES academic_groups(group_id) ON DELETE RESTRICT,
    last_name   VARCHAR(50) NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    email       VARCHAR(100) NOT NULL UNIQUE
);

-- 1НФ: атомарне ПІБ; 3НФ: academic_rank винесено в довідник academic_ranks
CREATE TABLE teachers (
    teacher_id    SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    rank_id       INTEGER NOT NULL REFERENCES academic_ranks(rank_id) ON DELETE RESTRICT,
    last_name     VARCHAR(50) NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    middle_name   VARCHAR(50),
    email         VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE courses (
    course_id     SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    course_name   VARCHAR(150) NOT NULL,
    ects_credits  INTEGER NOT NULL CHECK (ects_credits BETWEEN 1 AND 12)
);

-- 1НФ: кожна роль - окремий рядок (без "Лекції та практики"); 3НФ: role_id -> assignment_roles
CREATE TABLE course_assignments (
    assignment_id SERIAL PRIMARY KEY,
    teacher_id    INTEGER NOT NULL REFERENCES teachers(teacher_id) ON DELETE RESTRICT,
    course_id     INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE RESTRICT,
    role_id       INTEGER NOT NULL REFERENCES assignment_roles(role_id) ON DELETE RESTRICT,
    academic_year INTEGER NOT NULL CHECK (academic_year >= 2000),
    CONSTRAINT unique_teacher_course_assignment UNIQUE (teacher_id, course_id, academic_year, role_id)
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id    INTEGER NOT NULL REFERENCES students(student_id) ON DELETE RESTRICT,
    course_id     INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE RESTRICT,
    semester      INTEGER NOT NULL CHECK (semester BETWEEN 1 AND 8),
    final_grade   INTEGER CHECK (final_grade BETWEEN 0 AND 100),
    status        VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Completed', 'Dropped')),
    CONSTRAINT unique_student_course_semester UNIQUE (student_id, course_id, semester),
    CONSTRAINT check_final_grade_status CHECK (
        (final_grade IS NOT NULL AND status = 'Completed' AND final_grade >= 60) OR
        (final_grade IS NULL AND status IN ('Active', 'Dropped'))
    )
);

-- 3НФ: work_type винесено в довідник work_types
CREATE TABLE grade_records (
    grade_id      SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL REFERENCES enrollments(enrollment_id) ON DELETE RESTRICT,
    teacher_id    INTEGER NOT NULL REFERENCES teachers(teacher_id) ON DELETE RESTRICT,
    work_type_id  INTEGER NOT NULL REFERENCES work_types(work_type_id) ON DELETE RESTRICT,
    score         INTEGER NOT NULL CHECK (score BETWEEN 0 AND 100),
    grade_date    DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ============
-- ТЕСТОВІ ДАНІ
-- ============

INSERT INTO academic_ranks (rank_name) VALUES
    ('Professor'),
    ('Associate Professor'),
    ('Senior Lecturer'),
    ('Lecturer');

INSERT INTO assignment_roles (role_name) VALUES
    ('Лекції'),
    ('Лабораторні роботи'),
    ('Практичні заняття');

INSERT INTO work_types (work_type_name, max_score) VALUES
    ('Лабораторна робота №1', 20),
    ('Лабораторна робота №2', 20),
    ('Модульна контрольна робота', 30);

INSERT INTO faculties (faculty_name, building_number) VALUES
    ('Факультет інформатики та обчислювальної техніки', 'Корпус 18'),
    ('Факультет прикладної математики', 'Корпус 15'),
    ('Радіотехнічний факультет', 'Корпус 7');

INSERT INTO departments (faculty_id, department_name, building_number, room_number) VALUES
    (1, 'Кафедра інформаційного забезпечення', 'Корпус 18', '401'),
    (1, 'Кафедра системного програмування', 'Корпус 18', '312'),
    (2, 'Кафедра прикладної математики', 'Корпус 15', '205');

INSERT INTO specialties (faculty_id, specialty_name, specialty_code) VALUES
    (1, 'Інженерія програмного забезпечення', '121'),
    (1, 'Комп''ютерні науки', '122'),
    (2, 'Прикладна математика', '113');

INSERT INTO academic_groups (specialty_id, group_name, admission_year) VALUES
    (1, 'ІМ-51', 2025),
    (1, 'ІМ-52', 2025),
    (2, 'КН-41', 2024);

INSERT INTO students (group_id, last_name, first_name, middle_name, email) VALUES
    (1, 'Демченко', 'Олександр', 'Стефанович', 'demchenko.o@student.kpi.ua'),
    (1, 'Коваленко', 'Марія', 'Ігорівна', 'kovalenko.m@student.kpi.ua'),
    (1, 'Сидоренко', 'Артем', 'Олегович', 'sydorenko.a@student.kpi.ua'),
    (2, 'Мельник', 'Дмитро', 'Володимирович', 'melnyk.d@student.kpi.ua'),
    (3, 'Ткаченко', 'Софія', 'Василівна', 'tkachenko.s@student.kpi.ua');

INSERT INTO teachers (department_id, rank_id, last_name, first_name, middle_name, email) VALUES
    (1, 1, 'Петров', 'Петро', 'Петрович', 'petrov.p@kpi.ua'),
    (1, 2, 'Іванов', 'Іван', 'Іванович', 'ivanov.i@kpi.ua'),
    (2, 3, 'Василенко', 'Олена', 'Сергіївна', 'vasylenko.o@kpi.ua'),
    (3, 4, 'Шевченко', 'Тарас', 'Григорович', 'shevchenko.t@kpi.ua');

INSERT INTO courses (department_id, course_name, ects_credits) VALUES
    (1, 'Бази даних та інформаційні системи', 5),
    (1, 'Об''єктно-орієнтоване програмування', 6),
    (2, 'Операційні системи', 4),
    (3, 'Дискретна математика', 5);

-- Запис "Лекції та практики" розділено на 2 атомарні записи
INSERT INTO course_assignments (teacher_id, course_id, role_id, academic_year) VALUES
    (1, 1, 1, 2025),
    (2, 1, 2, 2025),
    (3, 2, 1, 2025),
    (3, 2, 3, 2025),
    (4, 4, 1, 2025);

INSERT INTO enrollments (student_id, course_id, semester, final_grade, status) VALUES
    (1, 1, 2, 95, 'Completed'),
    (1, 2, 2, NULL, 'Active'),
    (2, 1, 2, 88, 'Completed'),
    (3, 1, 2, NULL, 'Active'),
    (4, 3, 4, 75, 'Completed');

INSERT INTO grade_records (enrollment_id, teacher_id, work_type_id, score, grade_date) VALUES
    (1, 1, 1, 100, '2026-03-01'),
    (2, 1, 2, 90, '2026-03-15'),
    (3, 1, 3, 95, '2026-04-01'),
    (4, 2, 1, 85, '2026-03-01'),
    (5, 3, 1, 70, '2026-03-01');