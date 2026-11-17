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
select ps.first_name || ' ' || ps.last_name as student_name, sg.group_name, c.course_name, e.grade, ppr.first_name || ' ' || ppr.last_name as lecturer_name
from enrolment e
left join student s using (student_id)
left join student_group_assignment sga using (student_id)
left join student_group sg using (group_id)
left join course c using (course_id)
left join course_teacher ct using (course_id)
left join professor pr using (professor_id)
left join person ppr on pr.person_id = ppr.person_id
left join person ps on s.person_id = ps.person_id
where e.grade < 60 and e.grade is not null and ct.professor_role in ('lecturer', 'full_ownership')
order by e.grade asc, sg.group_name, student_name, c.course_name