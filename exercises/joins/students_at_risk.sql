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
SELECT p1.first_name || ' ' || p1.last_name as student_name, sg.name as group_name, c.name as course_name, e.grade, 
p2.first_name || ' ' || p2.last_name as lecturer_name
FROM enrolment e
LEFT JOIN student s on e.student_id = s.student_id
LEFT JOIN person p1 on s.person_id = p1.person_id
LEFT JOIN student_group sg on s.group_id = sg.group_id
LEFT JOIN course c on e.course_id = c.course_id
LEFT JOIN course_teacher ct on e.course_id = ct.course_id
LEFT JOIN professor pp on ct.professor_id = pp.professor_id
LEFT JOIN person p2 on pp.person_id = p2.person_id
WHERE e.grade < 60 and ct.professor_role = 'лектор'
ORDER BY grade, group_name, student_name, course_name;