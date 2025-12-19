-- порахувати успішність студентів залежно від року навчання
select 
    c.student_year,
    s.surname,
    s.name,
    g.name,
    round(avg(e.grade), 2) as avg_grade
from public.student as s
join public.enrolment as e using (student_id)
join public.course as c using (course_id)
join public.student_group as g using (group_id)
group by c.student_year, s.student_id, s.surname, s.name, g.name
order by c.student_year asc, avg_grade desc;

-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
with group_avg_grades as (
    select  
        group_id, 
        avg(grade) as group_avg
    from public.student
    join public.enrolment using (student_id)
    group by group_id
)
select 
    s.surname,
    s.name,
    g.name,
    round(avg(e.grade), 2) as student_avg,
    round(gag.group_avg, 2) as group_avg,
    round(avg(e.grade) - gag.group_avg, 2) as difference
from public.student as s
join public.enrolment as e using (student_id)
join public.student_group as g using (group_id)
join group_avg_grades as gag using (group_id)
group by s.student_id, s.surname, s.name, g.name, gag.group_avg
order by g.name, student_avg desc;

-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
select 
    c.student_year,
    count(distinct c.course_id) as course_count,
    count(e.student_id) as enrollment_count,
    count(e.grade) as graded_students_count 
from public.course as c
left join public.enrolment as e using (course_id)
group by c.student_year
order by c.student_year;