-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента, потім за ідентифікатор студента

-- Рішення:
with student_count_courses as (
     select 
	       s.student_id,
		   p.first_name || ' ' || p.last_name AS full_name,
	       count(course_id) as course_number
	 from student s
	 left join enrolment e using(student_id)
	 left join person p using(person_id)
	 group by student_id, full_name
),
avg_count_courses as (
    select 
	      round(avg(course_number),2)::double precision as avg_number
	from student_count_courses sc

)

select *
from student_count_courses sc
cross join avg_count_courses ac
where course_number > avg_number
order by course_number DESC, full_name, student_id