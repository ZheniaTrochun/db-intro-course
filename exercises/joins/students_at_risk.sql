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
SELECT p.first_name || ' ' || p.last_name AS student_name, 
sg.name AS group_name, 
c.name AS course_name, 
e.grade AS grade, 
pr.first_name || ' ' || pr.last_name AS lecturer_name
FROM student s
LEFT JOIN person p ON s.person_id = p.person_id
LEFT JOIN student_group sg ON sg.group_id = s.group_id
LEFT JOIN enrolment e ON e.student_id = s.student_id
LEFT JOIN course c ON c.course_id = e.course_id
LEFT JOIN course_teacher ct ON c.course_id = ct.course_id
LEFT JOIN professor pf ON ct.professor_id = pf.professor_id
LEFT JOIN person pr ON pf.person_id = pr.person_id
WHERE e.grade < 60 AND e.grade IS NOT NULL AND ct.professor_role = 'лектор'
ORDER BY e.grade ASC, group_name, student_name, course_name;