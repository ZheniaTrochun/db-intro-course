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
select 
    p.first_name || ' ' || p.last_name as student_name,
    sg.name as group_name,
    c.name as course_name,
    e.grade as grade,
    p_lector.first_name || ' ' || p_lector.last_name as lecturer_name
from enrolment e
inner join student s_student on s_student.student_id = e.student_id
inner join person p on p.person_id = s_student.person_id
inner join student_group sg on sg.group_id = s_student.group_id
inner join course c on c.course_id = e.course_id
inner join course_teacher ct on ct.course_id = c.course_id
inner join professor pro on pro.professor_id = ct.professor_id
inner join person p_lector on p_lector.person_id = pro.person_id
where e.grade < 60 
    and e.grade is not null
    and ct.professor_role = u&'\043b\0435\043a\0442\043e\0440'
order by e.grade asc, group_name, student_name, course_name;