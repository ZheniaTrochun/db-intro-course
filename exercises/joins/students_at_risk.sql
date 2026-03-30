-- Завдання:
--      Вивести список студентів, які мають низькі оцінки (менше 60) разом з інформацією про курс та викладача
--      Очікувані колонки результату:
--          - повне ім'я студента (student_name)
--          - назва групи (group_name)
--          - назва курсу (course_name)
--          - оцінка (grade)
--          - повне ім'я лектора курсу (lecturer_name)
--      Включити тільки записи, де оцінка вже виставлена
--      Включити тільки лекторів
--      Результат відсортувати за:
--          - оцінкою (зростання), потім за назвою групи, потім за іменем студента, потім за назвою курсу

-- Рішення:
-- Рішення:
-- Рішення:
select 
    ps.first_name || ' ' || ps.last_name as student_name,
    g.name as group_name,
    c.name as course_name,
    e.grade,
    pt.first_name || ' ' || pt.last_name as lecturer_name
from enrolment e
join student s on e.student_id = s.student_id
join person ps on s.person_id = ps.person_id
join student_group g on s.group_id = g.group_id
join course c on e.course_id = c.course_id
join course_teacher ct on c.course_id = ct.course_id
join professor t on ct.professor_id = t.professor_id
join person pt on t.person_id = pt.person_id
where e.grade < 60 
  and e.grade is not null
  and ct.professor_role = 'лектор'
  and t.status = 'викладає'
order by 
    e.grade asc, 
    g.name asc, 
    student_name asc, 
    c.name asc;
