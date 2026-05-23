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
    s_pers.first_name || ' ' || s_pers.last_name AS student_name,
    sg.name AS group_name,
    crs.name AS course_name,
    enr.grade,
    p_pers.first_name || ' ' || p_pers.last_name AS lecturer_name
FROM enrolment enr
INNER JOIN student s ON enr.student_id = s.student_id
INNER JOIN person s_pers ON s.person_id = s_pers.person_id
INNER JOIN student_group sg ON s.group_id = sg.group_id
INNER JOIN course crs ON enr.course_id = crs.course_id
INNER JOIN course_teacher c_t ON crs.course_id = c_t.course_id
INNER JOIN professor prof ON c_t.professor_id = prof.professor_id
INNER JOIN person p_pers ON prof.person_id = p_pers.person_id
WHERE enr.grade IS NOT NULL
  AND enr.grade < 60
  AND c_t.professor_role = 'лектор'
ORDER BY enr.grade ASC, group_name, student_name, course_name;
