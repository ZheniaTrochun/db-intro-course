-- Завдання:
--      Вивести список студентів, які мають низькі оцінки (менше 60) разом з інформацією про курс та викладача
--      Очікувані колонки результату:
--          - повне ім'я студента (student_name)
--          - назва групи (group_name)
--          - назва курсу (course_name)
--          - оцінка (grade)
--          - повне ім'я лектора курсу (lecturer_name)
--      Включити тільки записи, де оцінка вже виставлена
--      Включити тільки лекторів (роль 'lecturer' або 'full_ownership')
--      Результат відсортувати за:
--          - оцінкою (зростання), потім за назвою групи, потім за іменем студента, потім за назвою курсу

-- Рішення:
select 
p_s.first_name || ' ' || p_s.last_name as student_name,
sg.group_name as group_name,
c.course_name as course_name,
e.grade as grade,
p_pr.first_name || ' ' || p_pr.last_name as lecturer_name
from enrolment e 
inner join course c 
on e.course_id = c.course_id
inner join course_teacher ct
on c.course_id = ct.course_id
inner join student s
on e.student_id = s.student_id
inner join person p_s
on s.person_id = p_s.person_id
inner join student_group_assignment sga
on s.student_id = sga.student_id
inner join student_group sg
on sga.group_id = sg.group_id
inner join professor pr
on ct.professor_id = pr.professor_id
inner join person p_pr
on pr.person_id = p_pr.person_id
where e.grade < 60 and ct.professor_role in ('lecturer', 'full_ownership')
order by grade asc, group_name, student_name, course_name; 