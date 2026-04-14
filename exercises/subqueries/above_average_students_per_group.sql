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

-- IO-45 Bondarchuk Mykhailo
-- Студенти з балом, вищим за середній по групі

WITH StudentAvg AS (
    SELECT
        e.student_id,
        s.group_id,
        AVG(e.grade) AS student_avg_grade
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    GROUP BY e.student_id, s.group_id
),
GroupAvg AS (
    SELECT
        s.group_id,
        AVG(e.grade) AS group_avg_grade
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    GROUP BY s.group_id
)
SELECT
    sa.student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sg.name AS group_name,
    ROUND(sa.student_avg_grade::numeric, 2) AS avg_student_grade,
    ROUND(ga.group_avg_grade::numeric, 2) AS avg_group_grade
FROM StudentAvg sa
JOIN GroupAvg ga ON sa.group_id = ga.group_id
JOIN student s ON sa.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
JOIN student_group sg ON sa.group_id = sg.group_id
WHERE sa.student_avg_grade > ga.group_avg_grade
ORDER BY
    group_name ASC,
    avg_student_grade DESC,
    full_name ASC;