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

SELECT p_stud.first_name || ' ' || p_stud.last_name AS student_name, sg.name AS group_name, c.name AS course_name, e.grade, p_prof.first_name || ' ' || p_prof.last_name AS lecturer_name
FROM student s
JOIN person p_stud ON s.person_id = p_stud.person_id
JOIN student_group sg ON s.group_id = sg.group_id
JOIN enrolment e ON s.student_id = e.student_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN person p_prof ON ct.professor_id = p_prof.person_id
WHERE e.grade < 60 AND e.grade IS NOT NULL 
AND ct.professor_role::text = 'лектор'
ORDER BY e.grade ASC, group_name ASC, student_name ASC, course_name ASC;