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
    ps.first_name || ' ' || ps.last_name AS student_name,
sg.group_name,
c.course_name,
e.grade,
pp.first_name || ' ' || pp.last_name AS lecturer_name
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
JOIN person ps ON s.person_id = ps.person_id
JOIN student_group_assignment sga ON s.student_id = sga.student_id
JOIN student_group sg ON sga.group_id = sg.group_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor pr ON ct.professor_id = pr.professor_id
JOIN person pp ON pr.person_id = pp.person_id
WHERE e.grade IS NOT NULL
AND e.grade < 60
AND ct.professor_role IN ('lecturer', 'full_ownership')
ORDER BY e.grade ASC, sg.group_name ASC, student_name ASC, c.course_name ASC;