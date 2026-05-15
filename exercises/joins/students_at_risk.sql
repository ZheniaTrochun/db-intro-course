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
SET client_encoding TO 'UTF8';
SELECT 
    per.first_name || ' ' || per.last_name AS student_name,
    gr.name AS group_name,
    c.name AS course_name,
    e.grade,
    t_per.first_name || ' ' || t_per.last_name AS lecturer_name
FROM enrolment e
JOIN student s USING(student_id)
JOIN person per ON s.person_id = per.person_id
JOIN student_group gr USING(group_id)
JOIN course c USING(course_id)
JOIN course_teacher ct USING(course_id)
JOIN professor pr ON ct.professor_id = pr.professor_id
JOIN person t_per ON pr.person_id = t_per.person_id
WHERE e.grade < 60 AND ct.professor_role = 'лектор'
ORDER BY e.grade, group_name, student_name, course_name;