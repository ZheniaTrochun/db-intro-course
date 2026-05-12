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
CONCAT_WS(' ', p_s.first_name, p_s.last_name) AS student_name, sg.name AS group_name, c.name AS course_name, e.grade,
CONCAT_WS(' ', p_prof.first_name, p_prof.last_name) AS lecturer_name
FROM enrolment e
INNER JOIN student s USING (student_id)
INNER JOIN person p_s ON s.person_id = p_s.person_id
INNER JOIN student_group sg USING (group_id)
INNER JOIN course c USING (course_id)
INNER JOIN course_teacher ct USING (course_id)
INNER JOIN professor prof USING (professor_id)
INNER JOIN person p_prof ON prof.person_id = p_prof.person_id
WHERE e.grade < 60
AND ct.professor_role = 'лектор'
ORDER BY 4 ASC, 2 ASC, 1 ASC, 3 ASC;