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
WITH course_count_of_student as (
    SELECT student_id, count(course_id) as course_number
    from enrolment e
    GROUP BY e.student_id
),
global_avg_course_count as (
    SELECT avg(course_number) as avg_number
    from course_count_of_student
)
SELECT ccof.student_id as "student_id", p.first_name || ' ' || p.last_name as "full_name",
       ccof.course_number as "course_number", cast(ROUND(cast(gacc.avg_number as numeric), 2) as float) as avg_number
from course_count_of_student ccof
	CROSS join global_avg_course_count gacc
	join student s ON ccof.student_id = s.student_id
	join person p ON s.person_id = p.person_id
WHERE ccof.course_number > gacc.avg_number
ORDER BY ccof.course_number desc, p.first_name || ' ' || p.last_name;