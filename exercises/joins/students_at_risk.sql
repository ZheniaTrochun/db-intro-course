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
    s.first_name || ' ' || s.second_name as student_name,
    g.group_name,
    c.course_name,
    e.grade,
    t.first_name || ' ' || t.second_name as lecturer_name
from enrollment e
join student s on e.student_id = s.student_id
join student_group g on s.group_id = g.group_id
join course c on e.course_id = c.course_id
join teacher t on c.faculty_id = t.faculty_id
where e.grade < 60 
  and e.grade is not null
  and t.status = 'викладає'
order by 
    e.grade asc, 
    g.group_name asc, 
    student_name asc, 
    c.course_name asc;
