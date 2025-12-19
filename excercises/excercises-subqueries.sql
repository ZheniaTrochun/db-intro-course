-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
with recursive course_hierarchy as (
    select 
        course_id, 
        name, 
        student_year::integer as min_year
    from public.course
    where course_id not in (select course_id from public.course_prerequisite)

    union all

    select 
        c.course_id, 
        c.name, 
		-- якщо курс має пререквізит, то його можна взяти на наступному -> +1
    	greatest(c.student_year, h.min_year + 1)
    from public.course as c
    join public.course_prerequisite as p on c.course_id = p.course_id
    join course_hierarchy as h on p.prerequisite_course_id = h.course_id
)
select 
    name, 
    max(min_year) as earliest_possible_year
from course_hierarchy
group by name
order by earliest_possible_year;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
with enrollment_stats as (
	select count(*)::float / count(distinct student_id) as couse_enrolment_avg from public.enrolment
)
select s.name, s.surname, count(e.course_id)
from public.enrolment as e
join public.student as s using (student_id)
group by s.student_id
having count(e.course_id) > (select couse_enrolment_avg from enrollment_stats)
order by s.student_id;

-- Знайти топ-3 студенти у кожному курсі за отриманими балами
with ranked_enrolments as (
    select 
        c.name as course_name,
        s.surname,
        s.name as student_name,
        e.grade,
        dense_rank() over (
            partition by c.course_id 
            order by e.grade desc
        ) as student_rank
    from public.enrolment as e
    join public.student as s using (student_id)
    join public.course as c using (course_id)
    where e.grade is not null
)
select 
    course_name,
    surname,
    student_name,
    grade,
    student_rank
from ranked_enrolments
where student_rank <= 3
order by course_name, student_rank;