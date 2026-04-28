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
 ps.first_name || ' ' || ps.last_name as student_name,
 sg.name as group_name,
 c.name as course_name,
 ROUND(e.grade, 2) as grade,
 pp.first_name || ' ' || pp.last_name as lecturer_name
FROM enrolment e
JOIN student s on e.student_id = s.student_id
JOIN person ps on s.person_id = ps.person_id
JOIN student_group sg on s.group_id = sg.group_id
JOIN course c on e.course_id = c.course_id
JOIN course_teacher ct on c.course_id = ct.course_id
JOIN professor prof on ct.professor_id = prof.professor_id
JOIN person pp on prof.person_id = pp.person_id
WHERE e.grade < 60 
 AND e.grade IS NOT NULL
 AND ct.professor_role::text = 'лектор'
ORDER BY grade ASC, group_name ASC, student_name ASC, course_name ASC;