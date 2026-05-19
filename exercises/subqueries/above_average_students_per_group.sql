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
-- Medgitova Sevil ІО-46

WITH student_avg AS (
    SELECT
        e.student_id,
        s.group_id,
        AVG(e.grade) AS avg_student_raw
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    GROUP BY e.student_id, s.group_id
),
group_avg AS (
    SELECT
        s.group_id,
        AVG(e.grade) AS avg_group_raw
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    GROUP BY s.group_id
)
SELECT
    sa.student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sg.name AS group_name,
    CAST(ROUND(sa.avg_student_raw::numeric, 2) AS DOUBLE PRECISION) AS avg_student_grade,
    CAST(ROUND(ga.avg_group_raw::numeric, 2) AS DOUBLE PRECISION) AS avg_group_grade
FROM student_avg sa
JOIN group_avg ga ON sa.group_id = ga.group_id
JOIN student s ON sa.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
JOIN student_group sg ON sa.group_id = sg.group_id
WHERE ROUND(sa.avg_student_raw::numeric, 2) > ROUND(ga.avg_group_raw::numeric, 2)
ORDER BY
    group_name ASC,
    sa.avg_student_raw DESC,
    full_name ASC,
    sa.student_id ASC;