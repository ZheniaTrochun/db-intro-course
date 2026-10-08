CREATE TYPE student_status AS ENUM ('enrolled', 'on_leave', 'graduated', 'expelled');

CREATE TABLE users (
    user_id           SERIAL PRIMARY KEY,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(150) UNIQUE NOT NULL,
    date_of_birth     DATE,
    registration_date DATE DEFAULT CURRENT_DATE,
    status            VARCHAR(30)
);

CREATE TABLE department (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE dorm (
    dorm_id SERIAL PRIMARY KEY,
    address VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE rooms (
    room_id     SERIAL PRIMARY KEY,
    dorm_id     INTEGER NOT NULL REFERENCES dorm(dorm_id),
    room_number VARCHAR(10) NOT NULL,
    floor       INTEGER
);

CREATE TABLE student (
    student_id      SERIAL PRIMARY KEY,
    enrollment_year INTEGER,
    dorm_id         INTEGER REFERENCES dorm(dorm_id) ON DELETE SET NULL,
    room_id         INTEGER REFERENCES rooms(room_id) ON DELETE SET NULL,
    status          student_status NOT NULL DEFAULT 'enrolled',
    user_id         INTEGER NOT NULL REFERENCES users(user_id)
);

CREATE TABLE dorm_admin (
    admin_id SERIAL PRIMARY KEY,
    user_id  INTEGER NOT NULL REFERENCES users(user_id),
    dorm_id  INTEGER NOT NULL REFERENCES dorm(dorm_id)
);

CREATE TABLE parking_slots (
    parking_slot_id SERIAL PRIMARY KEY,
    student_id      INTEGER REFERENCES student(student_id) ON DELETE SET NULL,
    dorm_id         INTEGER NOT NULL REFERENCES dorm(dorm_id),
    admin_id        INTEGER REFERENCES dorm_admin(admin_id) ON DELETE SET NULL,
    slot_number     VARCHAR(10) NOT NULL
);

CREATE TABLE course (
    course_id     SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES department(department_id),
    course_title  VARCHAR(100) NOT NULL
);

CREATE TABLE enrollment (
    enrollment_id   SERIAL PRIMARY KEY,
    student_id      INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    course_id       INTEGER NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade           VARCHAR(10),
    UNIQUE (student_id, course_id)
);

CREATE TABLE vacancy (
    vacancy_id   SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    job_name     VARCHAR(100) NOT NULL
);

CREATE TABLE application (
    application_id   SERIAL PRIMARY KEY,
    student_id       INTEGER NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    vacancy_id       INTEGER NOT NULL REFERENCES vacancy(vacancy_id) ON DELETE CASCADE,
    application_date DATE DEFAULT CURRENT_DATE,
    status           VARCHAR(30) DEFAULT 'submitted',
    UNIQUE (student_id, vacancy_id)
);


INSERT INTO users (first_name, last_name, email, date_of_birth, status) VALUES
    ('Іван',    'Петренко',  'ivan.petrenko@example.com',  '2003-05-14', 'active'),
    ('Марія',   'Коваль',    'maria.koval@example.com',    '2002-11-02', 'active'),
    ('Олег',    'Бондар',    'oleg.bondar@example.com',    '2001-03-20', 'active'),
    ('Анна',    'Сидоренко', 'anna.sydorenko@example.com', '2004-07-08', 'active'),
    ('Сергій',  'Мельник',   'sergiy.melnyk@example.com',  '1985-01-15', 'active'),
    ('Ольга',   'Ткаченко',  'olha.tkachenko@example.com', '1990-06-22', 'active'),
    ('Павло',   'Кравець',   'pavlo.kravets@example.com',  '1988-09-30', 'active'),
    ('Дмитро',  'Шевченко',  'dmytro.shevchenko@example.com', '2004-02-11', 'active');

INSERT INTO department (department_name) VALUES
    ('Комп''ютерні науки'),
    ('Економіка'),
    ('Іноземні мови');

INSERT INTO dorm (address) VALUES
    ('вул. Степана Бандери 1-б'),
    ('вул. Колотушкіна 1-а'),
    ('вул. Тараса Шевченка 1-в');

INSERT INTO rooms (dorm_id, room_number, floor) VALUES
    (1, '101', 1),
    (1, '102', 1),
    (2, '201', 2),
    (2, '202', 2),
    (3, '301', 3);

INSERT INTO student (enrollment_year, dorm_id, room_id, status, user_id) VALUES
    (2022, 1, 1,    'enrolled',  1),
    (2023, 1, 2,    'enrolled',  2),
    (2021, 2, 3,    'graduated', 3),
    (2022, 2, 4,    'on_leave',  4),
    (2024, NULL, NULL, 'enrolled', 8);

INSERT INTO dorm_admin (user_id, dorm_id) VALUES
    (5, 1),
    (6, 2),
    (7, 3);

INSERT INTO parking_slots (student_id, dorm_id, admin_id, slot_number) VALUES
    (1,    1, 1, 'P-101'),
    (3,    2, 2, 'P-201'),
    (4,    2, 2, 'P-202'),
    (NULL, 3, NULL, 'P-301');

INSERT INTO course (department_id, course_title) VALUES
    (1, 'Бази даних'),
    (1, 'Алгоритми та структури даних'),
    (2, 'Мікроекономіка'),
    (3, 'Англійська мова для IT');

INSERT INTO enrollment (student_id, course_id, enrollment_date, grade) VALUES
    (1, 1, '2022-09-01', NULL),
    (1, 2, '2022-09-01', NULL),
    (2, 1, '2023-09-01', NULL),
    (3, 3, '2021-09-01', '92'),
    (4, 4, '2022-09-01', NULL);

INSERT INTO vacancy (company_name, job_name) VALUES
    ('EPAM',        'Junior Developer'),
    ('Nova Poshta', 'Analyst'),
    ('Rozetka',     'Support Specialist');

INSERT INTO application (student_id, vacancy_id, application_date, status) VALUES
    (1, 1, '2024-03-01', 'submitted'),
    (1, 2, '2024-03-05', 'submitted'),
    (2, 2, '2024-03-02', 'accepted'),
    (3, 3, '2024-02-20', 'rejected');


SELECT * FROM users;
SELECT * FROM department;
SELECT * FROM dorm;
SELECT * FROM rooms;
SELECT * FROM student;
SELECT * FROM dorm_admin;
SELECT * FROM parking_slots;
SELECT * FROM course;
SELECT * FROM enrollment;
SELECT * FROM vacancy;
SELECT * FROM application;
