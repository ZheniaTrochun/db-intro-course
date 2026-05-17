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

ІО-41 Кореняко Антон

select p.first_name || ' ' || p.last_name as student_name, sg.name as group_name,
c.name as course_name, e.grade as grade, ppr.first_name || ' ' || ppr.last_name as lecturer_name

from enrolment e
join student s on e.student_id = s.student_id
join person p on s.person_id = p.person_id
join student_group sg on s.group_id = sg.group_id
join course c on e.course_id = c.course_id
join course_teacher ct on c.course_id = ct.course_id
join professor pr on ct.professor_id = pr.professor_id
join person ppr on pr.person_id = ppr.person_id

where e.grade < 60 and e.grade is not null and ct.professor_role = 'лектор'

order by grade, group_name, student_name, course_name
