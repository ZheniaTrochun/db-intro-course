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
    s_per.first_name || ' ' || s_per.last_name AS student_name, g.name AS group_name, 
    c.name AS course_name, e.grade AS grade, t_per.first_name || ' ' || t_per.last_name AS lecturer_name
FROM enrolment e
JOIN student st ON e.student_id = st.student_id
JOIN person s_per ON st.person_id = s_per.person_id
JOIN student_group g ON st.group_id = g.group_id
JOIN course c ON e.course_id = c.course_id
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor t ON ct.professor_id = t.professor_id
JOIN person t_per ON t.person_id = t_per.person_id
WHERE e.grade IS NOT NULL
  AND e.grade < 60
  AND ct.professor_role = 'лектор'
ORDER BY e.grade ASC, g.name,
        student_name, c.name