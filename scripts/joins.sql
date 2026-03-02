-- INNER JOIN
-- вивести список усіх студентів разом з інформацією про їхню групу
select p.first_name || ' ' || p.last_name as "full_name", sg.name
from student s
inner join student_group sg using(group_id)
inner join person p using(person_id)
order by sg.name, p.last_name, p.first_name;


-- сформувати список студентів, записаних на курс "бази даних"
-- додати імʼя групи
select p.first_name || ' ' || p.last_name as "student_name", sg.name as "group", c.name as "course"
from course c
inner join enrolment e using(course_id)
inner join student s using(student_id)
inner join student_group sg using(group_id)
inner join person p using(person_id)
where lower(c.name) = 'бази даних'
order by sg.name, p.last_name, p.first_name;


-- вивести інформацію про кожну групу разом з іменем старости та іменем куратора
select
	sg.name as "group",
	l_p.first_name || ' ' || l_p.last_name as "student_lead",
	curr_p.first_name || ' ' || curr_p.last_name as "student_curator"
from student_group sg
left join student_lead sl
	using (group_id)
left join student_curator sc
	using (group_id)
left join student curr
	on sc.student_id = curr.student_id
left join student l
	on sl.student_id = l.student_id
left join person curr_p
	on curr.person_id = curr_p.person_id
left join person l_p
	on l.person_id = l_p.person_id
where curr.student_id is null
order by sg.name;

-- LEFT JOIN
-- вивести список усіх професорів (які мають статус `'викладає'`) разом з курсами, які вони викладають
-- професори, які не прив'язані до жодного курсу, також мають бути у результаті


-- сформувати список курсів та пре-реквізитів
-- course -> prerequisite N


-- сформувати список всіх студентів та їх балів
-- сформувати список студентів на відрахування на основі балів


-- сформувати список всіх викладачів, які зараз не викладають


-- FULL OUTER JOIN
-- сформувати список кураторів, викладачів без кураторства та груп без куратора

update student_group set curator_id = null where group_id = 1;

select *
from professor prof
full outer join student_group sg on prof.professor_id = sg.curator_id;

-- UNION + JOIN
-- сформувати список контактів, що містить як професорів, так і студентів
-- для професорів вивести їхню посаду, для студентів — назву групи.

select
    p.first_name || ' ' || p.last_name as "full_name",
    p.phone_number,
    p.email,
    prof.job :: text as "details"
from professor prof
         inner join person p using (person_id)
union
select
    p.first_name || ' ' || p.last_name as "full_name",
    p.phone_number,
    p.email,
    sg.name as "details"
from student s
         inner join person p using (person_id)
         inner join student_group sg using (group_id);
