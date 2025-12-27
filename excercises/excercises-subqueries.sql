-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
with recursive academic_path as (
    -- сourses without prerequisites can be taken in year 1
    select 
        course_id, 
        name, 
        1 as theoretical_min_year
    from public.course
    where course_id not in (select course_id from public.course_prerequisite)

    union all

    -- recursive part: prerequisite year + 1
    select 
        c.course_id, 
        c.name, 
        ap.theoretical_min_year + 1
    from public.course as c
    join public.course_prerequisite as p on c.course_id = p.course_id
    join academic_path as ap on p.prerequisite_course_id = ap.course_id
)
select 
    name, 
    max(theoretical_min_year) as earliest_possible_year
from academic_path
group by name
order by earliest_possible_year;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
with course_stats as (
	select 
	-- one row in enrolment = one course for student => all courses / unique student
	-- numeric = float number with strict position of .
	    round(count(course_id)::numeric / count(distinct student_id), 2) as avg_courses_per_student
	from public.enrolment
)
select s.name, s.surname, count(e.course_id) as courses
from public.enrolment as e
right join public.student as s using (student_id)
cross join course_stats as cs
group by s.student_id, s.name, s.surname, cs.avg_courses_per_student
having count(e.course_id) > cs.avg_courses_per_student

-- Знайти топ-3 студенти у кожному курсі за отриманими балами
with ranked_data as (
	select 
		s.name,
		s.surname,
		c.name as course_name,
		coalesce(e.grade, 0) as grade,
		dense_rank() over (partition by c.course_id order by coalesce(e.grade, 0) desc) as student_rank
	from public.student as s
	inner join public.enrolment as e using (student_id)
	inner join public.course as c using (course_id)
)
select * from ranked_data 
where student_rank <= 3
order by course_name, student_rank;