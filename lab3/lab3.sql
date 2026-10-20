DROP TABLE IF EXISTS applications, vacancies, enrollments, courses, parking_slots, dorm_admins, students, rooms, dorms, departments, users CASCADE;
DROP TYPE  IF EXISTS student_status, user_status, application_status CASCADE;


CREATE TYPE student_status AS ENUM ('enrolled', 'on_leave', 'graduated', 'expelled');
CREATE TYPE user_status AS ENUM ('active', 'blocked');
CREATE TYPE application_status AS ENUM ('submitted', 'accepted', 'rejected');

CREATE TABLE dorms (
    dorm_id     SERIAL PRIMARY KEY,
    dorm_number INTEGER NOT NULL UNIQUE CHECK (dorm_number > 0),
    address     VARCHAR(150) UNIQUE NOT NULL CHECK (address = trim(address) AND address <> '')
);

CREATE TABLE users (
    user_id           SERIAL PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL CHECK (first_name = trim(first_name) AND first_name <> ''),
    last_name         VARCHAR(50)  NOT NULL CHECK (last_name = trim(last_name) AND last_name <> ''),
    email             VARCHAR(150) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$'),
    date_of_birth     DATE,
    registration_date DATE DEFAULT CURRENT_DATE,
    status            user_status NOT NULL DEFAULT 'active',
    dorm_id           INTEGER REFERENCES dorms(dorm_id) ON DELETE RESTRICT,
    UNIQUE (user_id, dorm_id)
);

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL CHECK (department_name = trim(department_name) AND department_name <> '')
);

CREATE TABLE rooms (
    room_id     SERIAL PRIMARY KEY,
    dorm_id     INTEGER NOT NULL REFERENCES dorms(dorm_id) ON DELETE RESTRICT,
    room_number VARCHAR(10) NOT NULL CHECK (room_number = trim(room_number) AND room_number <> ''),
    floor       INTEGER,
    UNIQUE (dorm_id, room_number),
    UNIQUE (room_id, dorm_id)
);

CREATE TABLE students (
    student_id      SERIAL PRIMARY KEY,
    enrollment_year INTEGER,
    dorm_id         INTEGER,
    room_id         INTEGER,
    status          student_status NOT NULL DEFAULT 'enrolled',
    user_id         INTEGER NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE RESTRICT,
    CHECK (room_id IS NULL OR dorm_id IS NOT NULL),
    CONSTRAINT fk_students_user_dorm
        FOREIGN KEY (user_id, dorm_id) REFERENCES users(user_id, dorm_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_students_room_same_dorm
        FOREIGN KEY (room_id, dorm_id) REFERENCES rooms(room_id, dorm_id)
        ON DELETE RESTRICT
);

CREATE TABLE dorm_admins (
    admin_id SERIAL PRIMARY KEY,
    user_id  INTEGER NOT NULL UNIQUE,
    dorm_id  INTEGER NOT NULL,
    CONSTRAINT fk_dorm_admins_user_dorm
        FOREIGN KEY (user_id, dorm_id) REFERENCES users(user_id, dorm_id)
        ON DELETE RESTRICT
);

CREATE TABLE parking_slots (
    parking_slot_id SERIAL PRIMARY KEY,
    dorm_id         INTEGER NOT NULL REFERENCES dorms(dorm_id) ON DELETE RESTRICT,
    user_id         INTEGER UNIQUE,
    slot_number     VARCHAR(10) NOT NULL CHECK (slot_number = trim(slot_number) AND slot_number <> ''),
    UNIQUE (dorm_id, slot_number),
    CONSTRAINT fk_parking_user_same_dorm
        FOREIGN KEY (user_id, dorm_id) REFERENCES users(user_id, dorm_id)
        ON DELETE SET NULL (user_id)
);

CREATE TABLE courses (
    course_id     SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    course_title  VARCHAR(100) NOT NULL CHECK (course_title = trim(course_title) AND course_title <> '')
);

CREATE TABLE enrollments (
    enrollment_id   SERIAL PRIMARY KEY,
    student_id      INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    course_id       INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade           NUMERIC,
    UNIQUE (student_id, course_id)
);

CREATE TABLE vacancies (
    vacancy_id   SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL CHECK (company_name = trim(company_name) AND company_name <> ''),
    job_name     VARCHAR(100) NOT NULL CHECK (job_name = trim(job_name) AND job_name <> '')
);

CREATE TABLE applications (
    application_id   SERIAL PRIMARY KEY,
    student_id       INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    vacancy_id       INTEGER NOT NULL REFERENCES vacancies(vacancy_id) ON DELETE CASCADE,
    application_date DATE DEFAULT CURRENT_DATE,
    status           application_status NOT NULL DEFAULT 'submitted',
    UNIQUE (student_id, vacancy_id)
);


INSERT INTO dorms (dorm_number, address) VALUES
    (1, 'вул. Степана Бандери 1-б'),
    (2, 'вул. Колотушкіна 1-а'),
    (3, 'вул. Тараса Шевченка 1-в'),
    (4, 'вул. Тараса Шевченка 2-в');

INSERT INTO users (first_name, last_name, email, date_of_birth, status, dorm_id) VALUES
    ('Іван',   'Петренко',  'ivan.petrenko@example.com',     '2003-05-14', 'active', 1),
    ('Марія',  'Коваль',    'maria.koval@example.com',       '2002-11-02', 'active', 1),
    ('Олег',   'Бондар',    'oleg.bondar@example.com',       '2001-03-20', 'active', 2),
    ('Анна',   'Сидоренко', 'anna.sydorenko@example.com',    '2004-07-08', 'active', 2),
    ('Сергій', 'Мельник',   'sergiy.melnyk@example.com',     '1985-01-15', 'active', 1),
    ('Ольга',  'Ткаченко',  'olha.tkachenko@example.com',    '1990-06-22', 'active', 1),
    ('Павло',  'Кравець',   'pavlo.kravets@example.com',     '1988-09-30', 'active', 3),
    ('Дмитро', 'Шевченко',  'dmytro.shevchenko@example.com', '2004-02-11', 'active', NULL),
    ('Степан', 'Бендера',   'stpbdn@gmail.com',              '2001-09-11', 'active', 2),
	('Бен', 'Мохамед',   'ben@gmail.com',              '2001-09-11', 'active', 2);

INSERT INTO departments (department_name) VALUES
    ('Комп''ютерні науки'),
    ('Економіка'),
    ('Іноземні мови');

INSERT INTO rooms (dorm_id, room_number, floor) VALUES
    (1, '101', 1),
    (1, '102', 1),
    (2, '201', 2),
    (2, '202', 2),
    (3, '301', 3),
    (3, '228', 2);

INSERT INTO students (enrollment_year, dorm_id, room_id, status, user_id) VALUES
    (2022, 1,    1,    'enrolled',  1),
    (2023, 1,    1,    'enrolled',  2),
    (2021, 2,    3,    'graduated', 3),
    (2022, 2,    4,    'on_leave',  4),
    (2024, NULL, NULL, 'enrolled',  8);

INSERT INTO dorm_admins (user_id, dorm_id) VALUES
    (5, 1),
    (6, 1),
    (9, 2),
    (7, 3);

INSERT INTO parking_slots (user_id, dorm_id, slot_number) VALUES
    (1, 1, 'P-101'),
    (2, 1, 'P-102'),
    (3, 2, 'P-201'),
    (4, 2, 'P-202'),
    (5, 1, 'P-103'),
    (9, 2, 'P-203'),
    (7, 3, 'P-301');

INSERT INTO parking_slots (dorm_id, slot_number) VALUES
    (3, 'P-302'),
    (4, 'P-401');

INSERT INTO courses (department_id, course_title) VALUES
    (1, 'Бази даних'),
    (1, 'Алгоритми та структури даних'),
    (2, 'Мікроекономіка'),
    (3, 'Англійська мова для IT');

INSERT INTO enrollments (student_id, course_id, enrollment_date, grade) VALUES
    (1, 1, '2022-09-01', NULL),
    (1, 2, '2022-09-01', NULL),
    (2, 1, '2023-09-01', NULL),
    (3, 3, '2021-09-01', 92),
    (4, 4, '2022-09-01', NULL);

INSERT INTO vacancies (company_name, job_name) VALUES
    ('EPAM',        'Junior Developer'),
    ('Nova Poshta', 'Analyst'),
    ('Rozetka',     'Support Specialist');

INSERT INTO applications (student_id, vacancy_id, application_date, status) VALUES
    (1, 1, '2024-03-01', 'submitted'),
    (1, 2, '2024-03-05', 'submitted'),
    (2, 2, '2024-03-02', 'accepted'),
    (3, 3, '2024-02-20', 'rejected');


SELECT * FROM users WHERE user_id >= 5;
SELECT * FROM departments;
SELECT * FROM dorms;
SELECT * FROM rooms;
SELECT * FROM students;
SELECT * FROM dorm_admins;
SELECT * FROM parking_slots;
SELECT * FROM courses;
SELECT * FROM enrollments;
SELECT * FROM vacancies;
SELECT * FROM applications;

UPDATE users
SET email = 'test@gmail.com'
WHERE user_id = 1;

DELETE FROM users
WHERE user_id = 10