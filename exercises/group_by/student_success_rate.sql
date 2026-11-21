-- Завдання:
--      Порахувати успішність студентів залежно від року вступу їхньої групи
--      Очікувані колонки результату:
--          - рік вступу групи (start_year) - student_group.start_year
--          - середній бал студентів груп цього року вступу (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком вступу групи (зростання)

-- Рішення:
select 
    sg.start_year,
    round(avg(e.grade), 2) as avg_grade
from student_group sg
join student_group_assignment sga on sg.group_id = sga.group_id
join enrolment e on sga.student_id = e.student_id
group by sg.start_year
order by sg.start_year asc;
