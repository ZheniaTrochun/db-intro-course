-- Завдання:
--      Знайти курси, на які записано більше ніж 100 студентів
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - кількість студентів (student_count)
--          - середній бал (avg_grade) - середній бал серед студентів, які вже отримали оцінку - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю студентів (спадання), потім за назвою курсу

-- Рішення:
select c.name as "course_name",
  count(*) as "student_count",
  round(avg(e.grade), 2) as "avg_grade"
from course c
inner join enrolment e using (course_id)
group by course_name
having count(*) > 100
order by student_count desc,
    course_name asc;
