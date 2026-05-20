-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:
select s.student_id, p.first_name || ' ' || p.last_name as full_name, round(avg(e.grade), 2) as average_grade
from student s
join person p on s.person_id = p.person_id
join enrolment e on s.student_id = e.student_id
where e.grade is not null
group by s.student_id, p.first_name, p.last_name
order by s.student_id
