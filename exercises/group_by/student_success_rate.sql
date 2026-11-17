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
    round(avg(grade), 2) as avg_grade
from
    enrolment e
    left join student s using (student_id)
    left join student_group_assignment sga using (student_id)
    left join student_group sg using (group_id)
group by
    sg.start_year
order by
    sg.start_year asc