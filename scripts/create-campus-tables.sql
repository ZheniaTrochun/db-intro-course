DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'person_status') THEN
create type person_status as enum ('registered', 'banned', 'inactive');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_status') THEN
create type student_status as enum ('active', 'expelled', 'graduated', 'academ');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'professor_status') THEN
create type professor_status as enum ('active', 'inactive', 'fired', 'vacation');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'study_level') THEN
create type study_level as enum ('bachelors', 'masters', 'phd');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'job_title') THEN
create type job_title as enum ('associate professor', 'professor', 'senior researcher');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_status') THEN
create type course_status as enum ('active', 'in development', 'retired', 'inactive');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'professor_role') THEN
create type professor_role as enum ('lecturer', 'practice', 'full_ownership');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enrolment_status') THEN
create type enrolment_status as enum ('not_started', 'started', 'finished');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_group_status') THEN
create type student_group_status as enum ('active', 'disbanned', 'graduated');
END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_group_assignment_status') THEN
create type student_group_assignment_status as enum ('active', 'inactive', 'graduated');
END IF;
END$$;

create table if not exists if not exists person
(
    person_id         int generated always as identity primary key,
    first_name        varchar(100)  not null,
    last_name         varchar(100)  not null,
    date_of_birth     DATE          not null,
    contact_medium    JSON,
    registration_date timestamp     not null default now(),
    person_status     person_status not null default 'registered'
);

create table if not exists student
(
    student_id     int generated always as identity primary key,
    person_id      int            not null references person (person_id),
    student_status student_status not null default 'active'
);

create table if not exists professor
(
    professor_id     int generated always as identity primary key,
    person_id        int              not null references person (person_id),
    start_year       date             not null default now(),
    professor_status professor_status not null default 'active',
    professor_degree study_level,
    job_title        job_title
);

create table if not exists course
(
    course_id     int generated always as identity primary key,
    course_name   varchar(100)  not null check (length(trim(both ' ' from course_name)) > 0),
    credits       int           not null check (credits > 0),
    course_status course_status not null default 'active'
);

create table if not exists course_teacher
(
    course_id     int           not null references course (course_id),
    professor_id  int           not null references professor (professor_id),
    profesor_role profesor_role not null,
    primary key (course_id, professor_id)
);

create table if not exists course_prerequisite
(
    course_id              int not null references course (course_id),
    prerequisite_course_id int not null references course (course_id),
    primary key (course_id, prerequisite_course_id)
);

create table if not exists enrolment
(
    student_id       int              not null references student (student_id),
    course_id        int              not null references course (course_id),
    grade            int,
    enrolment_status enrolment_status not null default 'not_started',
    created_at       timestamp        not null default now(),
    primary key (student_id, course_id)
);

create table if not exists specialties
(
    specialty_code     varchar(4)  not null primary key,
    field_of_knowledge varchar(25) not null
);

create table if not exists cohort
(
    cohort_id      int generated always as identity primary key,
    cohort_name    char(5)    not null,
    specialty_code varchar(4) not null references specialties (specialty_code)
);

create table if not exists student_group
(
    group_id     int generated always as identity primary key,
    group_name   varchar(8)           not null,
    start_year   smallint             not null check (start_year > 1898),
    end_year     smallint             not null check (end_year > start_year),
    study_level  study_level          not null,
    group_status student_group_status not null default 'active',
    curator_id   int                  not null references professor (professor_id),
    student_lead int references student (student_id),
    cohort_id    int                  not null references cohort (cohort_id)
);

create table if not exists student_group_assignment
(
    student_id        int                             not null references student (student_id),
    group_id          int                             not null references student_group (group_id),
    assignment_status student_group_assignment_status not null default 'active',
    primary key (student_id, group_id)
);
