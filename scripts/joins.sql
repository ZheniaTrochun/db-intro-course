-- INNER JOIN
-- сформувати список контактних даних студентів

select s.name, s.surname, cd.email, cd.phone
from student s
inner join contact_data cd
	on s.contact_data_id = cd.contact_data_id;

-- сформувати список студентів, записаних на курс "бази даних"
-- додати імʼя групи
select s.name, s.surname, g.name as "group name"
from course c
inner join enrolment e ON e.course_id = c.course_id
inner join student s on s.student_id = e.student_id
inner join student_group g on s.group_id = g.group_id
where c.course_id = 13;

-- сформувати список активних курсів з контактами відповідних викладачів

-- LEFT JOIN
-- сформувати список курсів та пре-реквізитів
-- course -> prerequisite N
select c.name, pc.name as prerequisite from course c
left join course_prerequisite p on c.course_id = p.course_id
left join course pc ON p.prerequisite_course_id = pc.course_id;

-- сформувати список всіх студентів та їх балів
-- сформувати список студентів на відрахування на основі балів
select s.name, s.surname, c.name, e.grade from student s
left join enrolment e on s.student_id = e.student_id
left join course c on e.course_id = c.course_id
where (e.grade < 60 OR e.grade is null) and e.course_id is not null;

-- сформувати список всіх викладачів, які зараз не викладають
select t.name, t.surname from teacher t
left join course c using (teacher_id)
where c.course_id is null;

-- FULL OUTER JOIN
-- сформувати список кураторів, викладачів без кураторства та груп без куратора

select * from student_group g full outer join teacher t on g.curator_id = t.teacher_id;

-- UNION + JOIN
-- знайти всі адреси пошти, які використовуються
select scd.email, scd.phone
from contact_data scd
inner join student s on s.contact_data_id = scd.contact_data_id
UNION
select tcd.email, tcd.phone
from contact_data tcd
inner join teacher t on t.contact_data_id = tcd.contact_data_id;
