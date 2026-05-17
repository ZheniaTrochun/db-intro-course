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
sg.name as group_name,
count(distinct s.student_id) as student_count,
round(avg(e.grade), 2) as avg_grade
from student_group sg
join student s on s.group_id = sg.group_id
join enrolment e on e.student_id = s.student_id
group by sg.group_id, sg.name
having avg(e.grade) > 75
order by avg_grade desc, group_name
