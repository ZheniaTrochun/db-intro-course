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

SELECT 
    p.first_name || ' ' || p.last_name AS student_name, 
    sg.group_name,
    c.course_name, 
    e.grade, 
    pers.first_name || ' ' || pers.last_name AS lecturer_name
FROM student s
INNER JOIN person p ON s.person_id = p.person_id
INNER JOIN student_group_assignment sga ON s.student_id = sga.student_id
INNER JOIN student_group sg ON sga.group_id = sg.group_id
INNER JOIN enrolment e ON s.student_id = e.student_id
INNER JOIN course c ON e.course_id = c.course_id
INNER JOIN course_teacher ct ON c.course_id = ct.course_id
INNER JOIN professor pr ON ct.professor_id = pr.professor_id
INNER JOIN person pers ON pr.person_id = pers.person_id
WHERE e.grade < 60 AND ct.professor_role IN ('lecturer', 'full_ownership')
ORDER BY e.grade, sg.group_name, student_name, c.course_name