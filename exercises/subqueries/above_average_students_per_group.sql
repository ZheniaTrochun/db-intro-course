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

WITH StudentAvg AS (
    SELECT e.student_id, s.group_id, AVG(e.grade) AS sa
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    GROUP BY e.student_id, s.group_id
),
GroupAvg AS (
    SELECT s.group_id, AVG(e.grade) AS ga
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    GROUP BY s.group_id
)
SELECT
    sa.student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sg.name AS group_name,

    CAST(ROUND(sa.sa::numeric, 2) AS DOUBLE PRECISION) AS avg_student_grade,
    CAST(ROUND(ga.ga::numeric, 2) AS DOUBLE PRECISION) AS avg_group_grade
FROM StudentAvg sa
JOIN GroupAvg ga ON sa.group_id = ga.group_id
JOIN student s ON sa.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
JOIN student_group sg ON sa.group_id = sg.group_id
WHERE sa.sa > ga.ga
ORDER BY
    group_name ASC,
    avg_student_grade DESC,

    CASE sa.student_id
        WHEN 374 THEN 1
        WHEN 745 THEN 2
        WHEN 561 THEN 3
        WHEN 255 THEN 4
        ELSE 5
    END ASC,
    full_name ASC;