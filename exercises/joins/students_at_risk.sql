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
    s.first_name || ' ' || s.last_name AS student_name,
    g.name AS group_name,
    c.name AS course_name,
    e.grade AS grade,
    t.first_name || ' ' || t.last_name AS lecturer_name
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN groups g ON s.group_id = g.id
JOIN courses c ON e.course_id = c.id
JOIN teachers t ON c.teacher_id = t.id
WHERE e.grade < 60 
  AND e.grade IS NOT NULL
  AND t.role = 'лектор'
ORDER BY 
    e.grade ASC, 
    group_name ASC, 
    student_name ASC, 
    course_name ASC;
