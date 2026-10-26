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
prsnstud.first_name || ' ' || prsnstud.last_name AS student_name,
g.group_name AS group_name,
c.course_name AS course_name,
e.grade AS grade,
prsnprof.first_name || ' ' || prsnprof.last_name AS lecturer_name
FROM student s
JOIN student_group_assignment ga ON s.student_id = ga.student_id
JOIN student_group g ON ga.group_id = g.group_id

JOIN enrolment e ON s.student_id = e.student_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON ct.course_id = c.course_id
JOIN professor prof ON prof.professor_id = ct.professor_id
JOIN person prsnprof ON prsnprof.person_id = prof.person_id

JOIN person prsnstud ON prsnstud.person_id = s.person_id
WHERE e.grade IS NOT NULL
AND e.grade < 60
AND ct.professor_role  IN ('lecturer', 'full_ownership')
ORDER BY grade ASC, group_name, student_name, course_name
