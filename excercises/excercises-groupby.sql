-- порахувати успішність студентів залежно від року навчання = avg grade for each student for each year
select 
	c.student_year, 
	s.name, 
	s.surname, 
	sg.name, 
	COALESCE(round(avg(e.grade), 2), 0)
from public.student as s
join public.student_group as sg using (group_id)
join public.enrolment as e using (student_id)
join public.course as c using (course_id)
where c.is_active = true
-- sql standart obliges that all fields in select must be in group by  
group by c.student_year, s.student_id, s.name, s.surname, sg.group_id, sg.name
order by c.student_year, sg.group_id

-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
with group_grade_avg as (
	-- if null => 0 and also play in avg grade of group
	select sg.group_id, AVG(COALESCE(e.grade, 0)) as avg_grade
	from public.enrolment as e 
	join public.student as s using (student_id)
	join public.student_group as sg using (group_id)
	group by sg.group_id
	order by sg.group_id
)
select 
	s.name, 
	s.surname, 
	sg.name, 
	-- if null => 0 and also play in avg grade for student
	round(avg(coalesce(e.grade, 0)), 2) as student_avg,
	round(gga.avg_grade, 2) as group_avg,
	round(gga.avg_grade, 2) - round(avg(coalesce(e.grade, 0)), 2) as diff
from public.enrolment as e  
-- all student even if they don't have courses
right join public.student as s using (student_id)
join public.student_group as sg using (group_id)
join group_grade_avg as gga using (group_id)
group by s.student_id, s.name, s.surname, sg.group_id, sg.name, gga.avg_grade
order by sg.name, student_avg desc;

-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
select 
	c.student_year, 
	count(distinct e.course_id) as course_count,
	count(e.student_id) as student_count,
	-- count igonore null fields
	count(e.grade) as graded_students
from public.enrolment as e
-- all courses even without students
right join public.course as c using (course_id)
group by c.student_year
order by c.student_year