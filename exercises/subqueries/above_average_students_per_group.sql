-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:
WITH student_avg AS (
    SELECT
        s.student_id,
        pers.first_name || ' ' || pers.last_name AS full_name,
        s.group_id,
        AVG(enr.grade) AS avg_student_grade
    FROM student s
    INNER JOIN person pers ON s.person_id = pers.person_id
    INNER JOIN enrolment enr ON s.student_id = enr.student_id
    GROUP BY s.student_id, pers.first_name, pers.last_name, s.group_id
),
group_avg AS (
    SELECT
        sg.group_id,
        sg.name AS group_name,
        AVG(enr.grade) AS avg_group_grade
    FROM student_group sg
    INNER JOIN student s ON sg.group_id = s.group_id
    INNER JOIN enrolment enr ON s.student_id = enr.student_id
    GROUP BY sg.group_id, sg.name
)
SELECT
    sa.student_id,
    sa.full_name,
    ga.group_name,
    ROUND(sa.avg_student_grade, 2) AS avg_student_grade,
    ROUND(ga.avg_group_grade, 2) AS avg_group_grade
FROM student_avg sa
INNER JOIN group_avg ga ON sa.group_id = ga.group_id
WHERE ROUND(sa.avg_student_grade, 2) > ROUND(ga.avg_group_grade, 2)
ORDER BY ga.group_name, sa.avg_student_grade DESC, sa.full_name;
