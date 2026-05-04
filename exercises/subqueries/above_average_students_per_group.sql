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

--Рішення:
WITH StudentRaw AS (
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        AVG(e.grade::numeric) AS s_avg
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
GroupRaw AS (
    SELECT
        s.group_id,
        AVG(e.grade::numeric) AS g_avg
    FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
),
FilteredData AS (
    SELECT
        sa.student_id,
        sa.full_name,
        TRIM(sg.name) AS group_name,
        CAST(ROUND(sa.s_avg, 2) AS NUMERIC(38,2)) AS avg_student_grade,
        CAST(ROUND(ga.g_avg, 2) AS NUMERIC(38,2)) AS avg_group_grade
    FROM StudentRaw sa
    JOIN GroupRaw ga ON sa.group_id = ga.group_id
    JOIN student_group sg ON sa.group_id = sg.group_id
    WHERE sa.s_avg > ga.g_avg
)
SELECT
    CAST(ROW_NUMBER() OVER (ORDER BY group_name ASC, avg_student_grade DESC, full_name ASC) - 1 AS INTEGER) AS row_number,
    student_id,
    full_name,
    group_name,
    avg_student_grade,
    avg_group_grade
FROM FilteredData
ORDER BY
    group_name ASC,
    avg_student_grade DESC,
    full_name ASC;