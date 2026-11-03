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
select p.first_name || ' ' || p.last_name as student_name,
       sg.group_name, c.course_name, e.grade,
       pl.first_name || ' ' || pl.last_name as lecturer_name
from student s
left join person p on s.person_id = p.person_id
left join student_group_assignment sga on s.student_id = sga.student_id
left join enrolment e on s.student_id = e.student_id
left join student_group sg on sga.group_id = sg.group_id
left join course c on e.course_id = c.course_id
left join course_teacher ct on c.course_id = ct.course_id
left join professor pr on ct.professor_id = pr.professor_id
left join person pl on pr.person_id = pl.person_id
where e.grade < 60 and professor_role in ('lecturer', 'full_ownership')
order by e.grade ASC, sg.group_name, student_name, c.course_name;