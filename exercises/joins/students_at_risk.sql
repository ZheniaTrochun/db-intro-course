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
    sp.first_name || ' ' || sp.last_name AS student_name,
    sg.name AS group_name,
    c.name AS course_name,
    e.grade,
    pp.first_name || ' ' || pp.last_name AS lecturer_name
FROM enrolment e
JOIN student s 
    ON s.student_id = e.student_id
JOIN person sp 
    ON sp.person_id = s.person_id
JOIN student_group sg 
    ON sg.group_id = s.group_id
JOIN course c 
    ON c.course_id = e.course_id
JOIN course_teacher ct 
    ON ct.course_id = c.course_id
JOIN professor p 
    ON p.professor_id = ct.professor_id
JOIN person pp 
    ON pp.person_id = p.person_id
WHERE 
    e.grade IS NOT NULL
    AND e.grade < 60
    AND ct.professor_role = 'лектор'
ORDER BY 
    e.grade ASC,
    sg.name ASC,
    student_name ASC,
    c.name ASC;