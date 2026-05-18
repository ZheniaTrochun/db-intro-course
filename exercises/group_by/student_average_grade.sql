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
select s.student_id as "student_id",
  p.first_name || ' ' || p.last_name as "full_name",
  round(avg(e.grade), 2) as "avg_student_grade",
  sg.name as "group_name",
  round((avg(avg(e.grade)) over (partition by s.group_id)), 2) as "avg_group_grade"
from enrolment e
join student s on s.student_id = e.student_id
join person p on s.person_id = p.person_id
join student_group sg on s.group_id = sg.group_id
group by s.student_id,
  p.first_name,
  p.last_name,
  sg.name,
  s.group_id
order by group_name,
  full_name;
