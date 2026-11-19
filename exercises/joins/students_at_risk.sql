-- Завдання:
--      Вивести список студентів, які мають низькі оцінки (менше 60) разом з інформацією про курс та викладача
--      Очікувані колонки результату:
--          - повне ім'я студента (student_name)
--          - назва групи (group_name)
--          - назва курсу (course_name)
--          - оцінка (grade)
--          - повне ім'я лектора курсу (lecturer_name)
--      Включити тільки записи, де оцінка вже виставлена
--      Включити тільки лекторів (роль 'lecturer' або 'full_ownership')
--      Результат відсортувати за:
--          - оцінкою (зростання), потім за назвою групи, потім за іменем студента, потім за назвою курсу

-- Рішення:
WITH low_grades AS (
    SELECT student_id, course_id, grade
    FROM enrolment
    WHERE grade IS NOT NULL
      AND grade < 60
)
SELECT
    sp.first_name || ' ' || sp.last_name AS student_name,
    sg.group_name AS group_name,
    c.course_name AS course_name,
    lg.grade AS grade,
    lp.first_name || ' ' || lp.last_name AS lecturer_name
FROM low_grades AS lg
JOIN student AS s
    ON s.student_id = lg.student_id
JOIN person AS sp
    ON sp.person_id = s.person_id
JOIN student_group_assignment AS sga
    ON sga.student_id = s.student_id
JOIN student_group AS sg
    ON sg.group_id = sga.group_id
JOIN course AS c
    ON c.course_id = lg.course_id
JOIN course_teacher AS ct
    ON ct.course_id = c.course_id
   AND ct.professor_role IN ('lecturer', 'full_ownership')
JOIN professor AS p
    ON p.professor_id = ct.professor_id
JOIN person AS lp
    ON lp.person_id = p.person_id
ORDER BY
    lg.grade ASC,
    sg.group_name ASC,
    student_name ASC,
    c.course_name ASC;
