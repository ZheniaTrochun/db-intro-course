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
    c.name AS course_name,
    p.first_name || ' ' || p.last_name AS teacher_name,
    e.grade
FROM campus.students s
JOIN campus.enrolments e ON s.id = e.student_id
JOIN campus.courses c ON e.course_id = c.id
JOIN campus.professor_course pc ON c.id = pc.course_id
JOIN campus.professors p ON pc.professor_id = p.id
WHERE e.grade < 60
ORDER BY e.grade ASC;