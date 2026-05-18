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
select student_person.first_name || ' ' || student_person.last_name as "student_name",
  sg.name as "group_name",
  c.name as "course_name",
  e.grade,
  professor_person.first_name || ' ' || professor_person.last_name as "lecturer_name"
from student s
left join person student_person on student_person.person_id = s.person_id
left join student_group sg on sg.group_id = s.group_id
left join enrolment e on e.student_id = s.student_id
left join course c on c.course_id = e.course_id
left join course_teacher cs on cs.course_id = c.course_id
left join professor prof on prof.professor_id = cs.professor_id
left join person professor_person on professor_person.person_id = prof.person_id 
where e.grade < 60 and e.grade is not null and cs.professor_role = 'лектор'
order by e.grade asc,
    sg.name,
    student_name,
    course_name;
