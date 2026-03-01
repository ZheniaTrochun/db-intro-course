create table if not exists person
(
    person_id    serial primary key,
    first_name   varchar(25)        NOT NULL,
    last_name    varchar(32)        NOT NULL,
    birth_date   date               NOT NULL,
    phone_number char(12)           NOT NULL,
    email        varchar(64) unique NOT NULL
);

-- workaround for missing `IF NOT EXISTS` for types creation
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'professor_status') THEN
        create type professor_status as enum ('викладає', 'звільнений', 'у відпустці');
    END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'professor_role') THEN
        create type professor_role as enum ('асистент', 'старший викладач', 'доцент', 'професор');
    END IF;
END$$;

create table if not exists professor
(
    professor_id serial primary key,
    status       professor_status not null,
    job          professor_role,
    person_id    int              not null references person (person_id)
);

create table if not exists student_group
(
    group_id   serial primary key,
    name       char(7) not null check (name LIKE '__-%'),
    start_year smallint
);

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_status') THEN
        create type student_status as enum ('навчається', 'випускник', 'академ', 'відрахований', 'абітурієнт');
    END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_form_of_study') THEN
        create type student_form_of_study as enum ('денна', 'заочна', 'вечірня', 'дистанційна');
    END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'student_finance_source') THEN
        create type student_finance_source as enum ('контракт', 'бюджет', 'відпрацювання');
    END IF;
END$$;

create table if not exists student
(
    student_id     SERIAL PRIMARY KEY,
    course         int check (course >= 1 and course <= 6),
    start_date     date,
    end_date       date,
    status         student_status not null,
    form_of_study  student_form_of_study,
    finance_source student_finance_source,
    person_id      int            not null references person (person_id),
    tutor          int references professor (professor_id),
    group_id       int references student_group (group_id)
);

create table if not exists student_curator
(
    student_id int references student (student_id),
    group_id   int references student_group (group_id),
    primary key (student_id, group_id)
);

create table if not exists student_lead
(
    student_id int references student (student_id),
    group_id   int references student_group (group_id) unique,
    primary key (student_id, group_id)
);

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_control_type') THEN
        create type course_control_type as enum ('екзамен', 'залік');
    END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_study_type') THEN
        create type course_study_type as enum ('очна', 'дистанційна', 'асинхронна');
    END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_status') THEN
        create type course_status as enum ('активний', 'неактивний', 'в розробці');
    END IF;
END$$;

create table if not exists course
(
    course_id    serial primary key,
    name         varchar(64)         not null,
    hours        smallint            not null check (hours > 0 and hours < 350),
    credits      smallint            not null check (credits > 0),
    control_type course_control_type not null,
    study_type   course_study_type   not null default 'очна',
    status       course_status       not null
);

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_teacher_role') THEN
        create type course_teacher_role as enum ('лектор', 'викладач практики');
    END IF;
END$$;

create table if not exists course_teacher
(
    course_id      int                 not null references course (course_id),
    professor_id   int                 not null references professor (professor_id),
    professor_role course_teacher_role not null,
    primary key (course_id, professor_id, professor_role)
);

create table if not exists course_prerequisite
(
    course_id               int not null references course (course_id),
    prerequisite_course_id  int not null references course (course_id),
    primary key (course_id, prerequisite_course_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'enrolment_status') THEN
        create type enrolment_status as enum ('новий запис', 'активний', 'курс завершено');
    END IF;
END$$;

create table if not exists enrolment
(
    student_id int not null references student(student_id),
    course_id int not null references course(course_id),
    grade int check (grade >= 0 and grade <= 100),
    enrolment_date date not null default now(),
    start_year smallint not null,
    status enrolment_status not null,
    primary key (student_id, course_id)
);
