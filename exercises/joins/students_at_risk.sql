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
SELECT
CONCAT(s.first_name, ' ', s.last_name) AS student_name, g.name AS group_name, c.name AS course_name, e.grade,
CONCAT(p.first_name, ' ', p.last_name) AS lecturer_name
FROM student s
JOIN student_group g ON s.group_id = g.group_id
JOIN enrolment e ON s.student_id = e.student_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor prof ON ct.professor_id = prof.professor_id
JOIN person p ON prof.person_id = p.person_id
WHERE e.grade IS NOT NULL
AND e.grade < 60
AND ct.professor_role = 'лектор'
ORDER BY e.grade ASC, group_name ASC, student_name ASC, course_name ASC;
