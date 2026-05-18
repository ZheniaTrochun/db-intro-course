-- порахувати розміри груп
insert INTO student_group ("name", start_year) values ('IO-21', 2022);

select * from student_group;

select sg.name, count(student_id) as group_size
from student_group sg left join student s using(group_id)
group by sg.group_id;

-- порахувати навантаження викладачів - скільки активних курсів та кредитів викладає кожен з викладачів
select
	p.first_name || ' ' || p.last_name as full_name,
	count(distinct course_id) as course_count,
	coalesce(sum(credits), 0) as sum_of_credits
from professor prof
	left join course_teacher ct using (professor_id)
	left join course c using (course_id)
	left join person p using (person_id)
where c.status = 'активний' or c.status is null
group by prof.professor_id, p.first_name, p.last_name;

-- знайти усіх студентів, середній бал яких більше 90
select
	e.student_id,
	p.first_name || ' ' || p.last_name as full_name,
	round(avg(grade), 2) as avg_grade
from enrolment e inner join student s using (student_id) inner join person p using (person_id)
GROUP by e.student_id, p.first_name, p.last_name
having avg(grade) > 90;

-- отримати оцінки студентів у порівнянні з середнім балом по предмету
-- додати середній бал студента
select
	e.student_id,
	p.first_name || ' ' || p.last_name as full_name,
	e.course_id,
	c.name,
	grade,
	avg(grade) over (partition by course_id) as avg_course_grade
from enrolment e
	inner join student s using (student_id)
	inner join person p using (person_id)
	inner join course c using (course_id);

-- побудувати список за успішністю по групам
select
    sg."name",
    p.first_name || ' ' || p.last_name as full_name,
    coalesce(round(avg(grade), 2), 0) as student_avg_grade,
    rank() over (partition by sg.name order by coalesce(avg(grade), 0) desc) as student_rank
from student s
         inner join student_group sg using (group_id)
         inner join person p using (person_id)
         left join enrolment e using (student_id)
group by sg.name, s.student_id, p.first_name, p.last_name
order by sg.name, student_rank;
