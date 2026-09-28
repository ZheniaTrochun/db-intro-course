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

CREATE TABLE student (
    student_id      SERIAL PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    enrollment_year INTEGER,
    dorm_id         INTEGER REFERENCES dorm(dorm_id),
    status          student_status NOT NULL DEFAULT 'enrolled',
    user_id         INTEGER REFERENCES users(user_id)
);

CREATE TABLE admin_of_the_dorm (
    admin_id   SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(150) UNIQUE NOT NULL,
    user_id    INTEGER REFERENCES users(user_id),
    dorm_id    INTEGER REFERENCES dorm(dorm_id)
);

CREATE TABLE rooms (
    room_id    SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES student(student_id),
    dorm_id    INTEGER REFERENCES dorm(dorm_id)
);

CREATE TABLE parking_slots (
    parking_slot_id SERIAL PRIMARY KEY,
    student_id      INTEGER REFERENCES student(student_id),
    dorm_id         INTEGER REFERENCES dorm(dorm_id),
    admin_id        INTEGER REFERENCES admin_of_the_dorm(admin_id)
);

CREATE TABLE course (
    course_id     SERIAL PRIMARY KEY,
    department_id INTEGER REFERENCES department(department_id),
    student_id    INTEGER REFERENCES student(student_id)
);

CREATE TABLE vacancy (
    vacancy_id   SERIAL PRIMARY KEY,
    student_id   INTEGER REFERENCES student(student_id),
    company_name VARCHAR(100),
    job_name     VARCHAR(100)
);


INSERT INTO users (first_name, last_name, email, date_of_birth, status) VALUES
    ('Іван',   'Петренко',  'ivan.petrenko@example.com',  '2003-05-14', 'active'),
    ('Марія',  'Коваль',    'maria.koval@example.com',    '2002-11-02', 'active'),
    ('Олег',   'Бондар',    'oleg.bondar@example.com',    '2001-03-20', 'active'),
    ('Анна',   'Сидоренко', 'anna.sydorenko@example.com', '2004-07-08', 'active'),
    ('Сергій', 'Мельник',   'sergiy.melnyk@example.com',  '1985-01-15', 'active'),
    ('Ольга',  'Ткаченко',  'olha.tkachenko@example.com', '1990-06-22', 'active'),
    ('Павло',  'Кравець',   'pavlo.kravets@example.com',  '1988-09-30', 'active');

INSERT INTO department (department_name) VALUES
    ('Комп''ютерні науки'),
    ('Економіка'),
    ('Іноземні мови');

INSERT INTO dorm (address) VALUES
    ('вул. Степана Бандери 1-б'),
    ('вул. Колотушкіна 1-а'),
    ('вул. Тараса Шевченка 1-в');

INSERT INTO student (first_name, last_name, email, enrollment_year, dorm_id, status, user_id) VALUES
    ('Іван',  'Петренко',  'ivan.student@example.com',  2022, 1, 'enrolled',  1),
    ('Марія', 'Коваль',    'maria.student@example.com', 2023, 1, 'enrolled',  2),
    ('Олег',  'Бондар',    'oleg.student@example.com',  2021, 2, 'graduated', 3),
    ('Анна',  'Сидоренко', 'anna.student@example.com',  2022, 2, 'on_leave',  4);

INSERT INTO admin_of_the_dorm (first_name, last_name, email, user_id, dorm_id) VALUES
    ('Сергій', 'Мельник',  'sergiy.admin@example.com', 5, 1),
    ('Ольга',  'Ткаченко', 'olha.admin@example.com',   6, 2),
    ('Павло',  'Кравець',  'pavlo.admin@example.com',  7, 3);

INSERT INTO rooms (student_id, dorm_id) VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 2);

INSERT INTO parking_slots (student_id, dorm_id, admin_id) VALUES
    (1, 1, 1),
    (3, 2, 2),
    (4, 2, 2);

INSERT INTO course (department_id, student_id) VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (3, 4);

INSERT INTO vacancy (student_id, company_name, job_name) VALUES
    (1, 'EPAM',        'Junior Developer'),
    (2, 'Nova Poshta', 'Analyst'),
    (3, 'Rozetka',     'Support Specialist');


SELECT * FROM users;
SELECT * FROM department;
SELECT * FROM dorm;
SELECT * FROM student;
SELECT * FROM admin_of_the_dorm;
SELECT * FROM rooms;
SELECT * FROM parking_slots;
SELECT * FROM course;
SELECT * FROM vacancy;