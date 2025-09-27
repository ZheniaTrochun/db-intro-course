CREATE TABLE IF NOT EXISTS contact_data
(
    contact_data_id serial PRIMARY KEY,
    email varchar(32) NOT NULL UNIQUE,
    phone varchar(32) NOT NULL UNIQUE
);

-- workaround for missing `IF NOT EXISTS` for types creation
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'qualification_name') THEN
        CREATE TYPE qualification_name AS ENUM ('бакалавр', 'магістр', 'доктор філософії', 'доктор наук');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS teacher
(
    teacher_id serial PRIMARY KEY,
    name varchar(32) NOT NULL,
    surname varchar(32) NOT NULL,
    contact_data_id integer not null references contact_data(contact_data_id),
    qualification qualification_name
);

CREATE TABLE IF NOT EXISTS student_group
(
    group_id serial PRIMARY KEY,
    name char(7) NOT NULL CHECK (name LIKE '__-%'),
    start_year SMALLINT NOT NULL CHECK (start_year >= 1898),
    curator_id INTEGER NOT NULL REFERENCES teacher(teacher_id)
);

CREATE TABLE IF NOT EXISTS student
(
    student_id serial PRIMARY KEY,
    name varchar(32) NOT NULL,
    surname varchar(32) NOT NULL,
    profession SMALLINT,
    contact_data_id integer not null references contact_data(contact_data_id),
    group_id integer not null references student_group(group_id)
);

CREATE TABLE IF NOT EXISTS course
(
    course_id serial PRIMARY KEY,
    name varchar(32) NOT NULL,
    credits SMALLINT NOT NULL CHECK (credits > 0 AND credits < 100),
    student_year SMALLINT NOT NULL CHECK (student_year >= 1 AND student_year <= 4),
    is_active BOOLEAN NOT NULL,
    teacher_id INTEGER NOT NULL REFERENCES teacher(teacher_id)
);

CREATE TABLE IF NOT EXISTS enrolment
(
    course_id INTEGER not null references course(course_id),
    student_id INTEGER not null references student(student_id),
    grade SMALLINT,
    PRIMARY KEY (course_id, student_id)
);

CREATE TABLE IF NOT EXISTS course_prerequisite
(
    course_id INTEGER NOT NULL references course(course_id),
    prerequisite_course_id INTEGER NOT NULL references course(course_id) CHECK (course_id <> prerequisite_course_id),
    PRIMARY KEY (course_id, prerequisite_course_id)
);
