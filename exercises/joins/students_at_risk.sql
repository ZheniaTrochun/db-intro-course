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
    sp.first_name || ' ' || sp.last_name AS student_name,
    sg.group_name                        AS group_name,
    c.course_name                        AS course_name,
    e.grade                              AS grade,
    lp.first_name || ' ' || lp.last_name AS lecturer_name
FROM enrolment e
JOIN student s                    ON s.student_id    = e.student_id
JOIN person sp                    ON sp.person_id    = s.person_id
JOIN student_group_assignment sga ON sga.student_id  = s.student_id
JOIN student_group sg             ON sg.group_id     = sga.group_id
JOIN course c                     ON c.course_id     = e.course_id
JOIN course_teacher ct            ON ct.course_id    = c.course_id
JOIN professor pr                 ON pr.professor_id = ct.professor_id
JOIN person lp                    ON lp.person_id    = pr.person_id
WHERE e.grade < 60
  AND ct.professor_role IN ('lecturer', 'full_ownership')
ORDER BY e.grade ASC, sg.group_name ASC, student_name ASC, c.course_name ASC;