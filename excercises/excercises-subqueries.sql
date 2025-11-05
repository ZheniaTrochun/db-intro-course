-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
with recursive min_semester as (
    select 
        c.course_id,
        c.name,
        1 as min_sem
    from course c
    where c.course_id not in (
        select course_id from course_prerequisite
    )

    union all

    select 
        cp.course_id,
        c1.name,
        ms.min_sem + 1
    from course_prerequisite cp
    join min_semester ms 
        on cp.prerequisite_course_id = ms.course_id
    join course c1 
        on c1.course_id = cp.course_id
)
select 
    course_id,
    name,
    max(min_sem) as min_req_semester
from min_semester
group by course_id, name
order by min_req_semester desc;
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
with course_count as (select s.name || ' ' || s.surname as full_name,
count(e.course_id) as c_count
from student s 
left join enrolment e using (student_id)
group by s.name, s.surname),

course_count_avg as (
    select avg(c_count) as course_count_avg
    from course_count
)

select 
cc.full_name,
cc.c_count as course_count,
ROUND(avg.course_count_avg, 1) as avg
from course_count cc, course_count_avg avg
where cc.c_count > avg.course_count_avg
order by cc.c_count desc;
-- Знайти топ-3 студенти у кожному курсі за отриманими балами
with ranked as (select 
c.name as course_name, 
s.name || ' ' || s.surname as full_name,
round(coalesce(avg(e.grade), 0), 2) as student_avg,
row_number() over (partition by c.name order by coalesce(avg(e.grade), 0) desc) as student_rank
from student s 
left join enrolment e using(student_id)
left join course c using(course_id)
group by c.name, s.name, s.surname)

select * from ranked 
where student_rank <=3
order by course_name asc, student_avg desc;
