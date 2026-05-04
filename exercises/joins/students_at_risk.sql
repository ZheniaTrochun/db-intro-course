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
SELECT p.first_name || ' ' || p.last_name as student_name, sg.name as group_name,
c.name as course_name, e.grade as grade, ppr.first_name || ' ' || ppr.last_name as lecturer_name
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
JOIN student_group sg ON s.group_id = sg.group_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor pr ON ct.professor_id = pr.professor_id
JOIN person ppr ON pr.person_id = ppr.person_id
WHERE e.grade < 60 AND e.grade is NOT NULL AND ct.professor_role = 'лектор'
ORDER BY grade, group_name, student_name, course_name