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
JOIN student s ON e.student_id = s.student_id
JOIN person sp ON s.person_id = sp.person_id
JOIN student_group sg ON s.group_id = sg.group_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor pr ON ct.professor_id = pr.professor_id
JOIN person pp ON pr.person_id = pp.person_id
WHERE e.grade IS NOT NULL 
  AND e.grade < 60
  AND ct.professor_role = 'лектор'
ORDER BY 
    e.grade ASC, 
    sg.name ASC, 
    student_name ASC, 
    c.name ASC;
