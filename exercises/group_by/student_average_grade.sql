-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента, потім за ідентифікатором студента

-- Рішення:

select
    s.student_id,
    p.first_name || ' ' || p.last_name                             as full_name,
    round(avg(e.grade), 2)                                       as avg_student_grade,
    sg.group_name,
    round(avg(avg(e.grade)) over (partition by sg.group_id), 2) as avg_group_grade
from enrolment e
    join student s using (student_id)
    join person p using (person_id)
    join student_group_assignment sga using (student_id)
    join student_group sg using (group_id)
group by s.student_id, p.person_id, sg.group_id
order by sg.group_name, full_name;

