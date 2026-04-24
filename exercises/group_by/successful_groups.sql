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
inner join student s on sg.group_id = s.group_id
inner join enrolment e on s.student_id = e.student_id
where e.grade is not null
group by sg.group_id, sg.name
having avg(e.grade) > 75
order by avg_grade desc, group_name;