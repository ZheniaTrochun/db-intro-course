-- порахувати розміри груп (включно з порожніми)

select distinct sg.group_name
from student_group sg
         left join student_group_assignment sga using (group_id);


select sg.group_name, count(sga.student_id) as group_size
from student_group sg
         left join student_group_assignment sga using (group_id)
group by group_id
order by sg.group_name;

-- порахувати навантаження викладачів - скільки активних курсів та кредитів викладає кожен з викладачів

select
    p.first_name || ' ' || p.last_name as name,
    count(c.course_id) as active_courses_count,
    coalesce(sum(c.credits), 0) as num_of_credits
from professor prof
         inner join person p using (person_id)
         left join course_teacher ct using (professor_id)
         left join course c on c.course_id = ct.course_id and course_status = 'active'
group by professor_id, p.first_name, p.last_name
order by name;

-- знайти усіх студентів, середній бал яких більше 90

select
    p.first_name || ' ' || p.last_name as name,
    round(coalesce(avg(grade), 0), 2) as avg_grade
from student s
         inner join person p using (person_id)
         left join enrolment e using (student_id)
group by student_id, p.first_name, p.last_name
having avg(grade) > 90;

-- отримати оцінки студентів у порівнянні з середнім балом по предмету
-- та з середнім балом самого студента

select
    p.first_name || ' ' || p.last_name as name,
    c.course_name,
    e.grade,
    round(avg(e.grade) over (partition by c.course_id), 2) as avg_course_grade,
    round(avg(e.grade) over (partition by s.student_id), 2) as avg_student_grade
from enrolment e
         inner join student s using (student_id)
         inner join person p using (person_id)
         inner join course c using (course_id);


-- побудувати список за успішністю по групах
select
    sg.group_name,
    p.first_name || ' ' || p.last_name as name,
    round(avg(e.grade), 2) as avg_student_grade,
    rank() over (partition by sg.group_name order by avg(e.grade) desc nulls last) as student_rank
from student s
         inner join person p using (person_id)
         inner join student_group_assignment sga using (student_id)
         inner join student_group sg using (group_id)
         left join enrolment e using (student_id)
group by p.person_id, sg.group_id
order by sg.group_name, student_rank;
