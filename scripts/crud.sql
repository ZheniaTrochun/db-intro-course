-- додати лектора
INSERT INTO contact_data(email, phone)
VALUES ('trochun.yevhenii@lll.kpi.ua', '380661769967');

SELECT * FROM contact_data WHERE phone = '380661769967';

INSERT INTO teacher(name, surname, contact_data_id, qualification)
VALUES ('Євгеній', 'Трочун', 21, 'доктор філософії');

SELECT * FROM teacher WHERE surname = 'Трочун';

-- додати курс "Бази даних"
INSERT INTO course(name, credits, student_year, is_active, teacher_id)
VALUES ('Бази даних', 5, 2, TRUE, 11);

SELECT * FROM course WHERE name = 'Бази даних';

-- записати студента на курс
INSERT INTO enrolment (course_id, student_id)
VALUES (13, 1),
(13, 5),
(13, 10);

SELECT * FROM enrolment WHERE course_id = 13;

-- знайти всіх студентів 121 спеціальності
SELECT * FROM student WHERE profession = 121;

-- знайти всіх студентів БЕЗ спеціальності
SELECT * FROM student WHERE profession IS NULL;

-- знайти всі курси, що викладаються на 2-му році навчання
-- знайти всі не активні курси
SELECT * FROM course WHERE NOT is_active;

-- знайти всі грути потоку ІТ-1Х
SELECT * FROM student_group;
SELECT * FROM student_group WHERE name = 'ІТ-1%';

-- знайти всіх викладачів, у кого рівень кваліфікації нижчий доктора філософії
SELECT * FROM teacher WHERE qualification NOT IN ('доктор філософії', 'доктор наук') OR qualification IS NULL;

-- порахувати середній бал студентів хто успішно здав сесію
SELECT AVG(grade) FROM enrolment WHERE grade > 60;

-- порахувати який відсоток студентів не склав сесію
SELECT
    count(distinct student_id) FILTER (WHERE grade is null OR grade < 60) as failed_students_count,
    count(distinct student_id) as total_students_count,
    (
        count(distinct student_id) FILTER (WHERE grade is null OR grade < 60) /
		count(distinct student_id)::real
        ) * 100 as failed_percent
FROM enrolment;

-- перевести студентів з МА-92 до ПС-91
SELECT * from student_group where NAME in ('МА-92', 'ПС-91');
select * from student where group_id = 3;
update student set group_id = 7 WHERE group_id = 3;

-- деактивувати курс комп мереж
select * from course;
update course set is_active = FALSE where course_id = 10;

-- видалити курс з кібербезпеки
select * from course;
delete from course where course_id = 12;
