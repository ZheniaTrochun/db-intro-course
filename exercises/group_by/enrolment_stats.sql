-- Завдання:
--      Порахувати статистику записів на курси для кожного року навчання
--      Очікувані колонки результату:
--          - рік навчання (student_year)
--          - кількість курсів (number_of_courses)
--          - кількість записів (number_of_enrolments)
--          - кількість студентів, що вже отримали бали (number_of_students_with_grade)
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
select 
	e.start_year as student_year,
	count(distinct e.course_id) as number_of_courses,
	count(*) as number_of_enrolments,
	count(e.grade) as number_of_students_with_grade
from enrolment e 
group by student_year
order by student_year asc