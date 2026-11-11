-- Завдання:
--      Порахувати успішність студентів залежно від року вступу їхньої групи
--      Очікувані колонки результату:
--          - рік вступу групи (start_year) - student_group.start_year
--          - середній бал студентів груп цього року вступу (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком вступу групи (зростання)

-- Рішення:

select
    sg.start_year          as student_year,
    round(avg(e.grade), 2) as avg_year_grade
from student_group sg
    join student_group_assignment sga using (group_id)
    join student s using (student_id)
    join enrolment e using (student_id)
group by sg.start_year
order by student_year asc;

