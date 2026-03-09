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
        student_id,
        ROUND(AVG(grade), 2) AS avg_student_grade
    FROM enrolments
    WHERE grade IS NOT NULL
    GROUP BY student_id
),
group_avg AS (
    SELECT
        s.group_id,
        ROUND(AVG(e.grade), 2) AS avg_group_grade
    FROM enrolments e
    JOIN students s ON e.student_id = s.id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)

SELECT
    s.id AS student_id,
    s.first_name || ' ' || s.last_name AS full_name,
    g.name AS group_name,
    sa.avg_student_grade,
    ga.avg_group_grade
FROM students s
JOIN groups g
    ON s.group_id = g.id
JOIN student_avg sa
    ON s.id = sa.student_id
JOIN group_avg ga
    ON s.group_id = ga.group_id
WHERE sa.avg_student_grade > ga.avg_group_grade
ORDER BY
    group_name ASC,
    avg_student_grade DESC,
    full_name ASC;