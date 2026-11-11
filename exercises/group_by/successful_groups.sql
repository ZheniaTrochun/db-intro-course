-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:

select
    sg.group_name,
    count(distinct student_id) as student_count,
    round(avg(e.grade), 2)     as avg_grade
from student_group sg
    join student_group_assignment sga using (group_id)
    join enrolment e using (student_id)
group by sg.group_id
having round(avg(e.grade), 2) > 75
order by avg_grade desc, sg.group_name;

