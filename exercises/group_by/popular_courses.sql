-- Завдання:
--      Знайти курси, на які записано більше ніж 100 студентів
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - кількість студентів (student_count)
--          - середній бал (avg_grade) - середній бал серед студентів, які вже отримали оцінку - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю студентів (спадання), потім за назвою курсу

-- Рішення:

select
    c.name as course_name,
    count(e.student_id) as student_count,
    round(avg(e.grade) filter (where e.grade is not null), 2) as avg_grade
from course c
join enrolment e on c.course_id = e.course_id
group by c.course_id, c.name
having count(e.student_id) > 100
order by student_count desc, course_name;
