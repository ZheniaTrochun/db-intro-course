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
        per.first_name || ' ' || per.last_name AS full_name,
        s.group_id,
        ROUND(AVG(e.grade), 2)                 AS avg_student_grade
    FROM student s
    JOIN person per       ON per.person_id = s.person_id
    LEFT JOIN enrolment e ON e.student_id = s.student_id AND e.grade IS NOT NULL
    GROUP BY s.student_id, per.first_name, per.last_name, s.group_id
),
group_avg AS (
    SELECT
        s.group_id,
        ROUND(AVG(e.grade), 2) AS avg_group_grade
    FROM student s
    JOIN enrolment e ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)
SELECT
    sa.student_id,
    sa.full_name,
    sg.name          AS group_name,
    sa.avg_student_grade,
    ga.avg_group_grade
FROM student_avg sa
JOIN group_avg ga     ON ga.group_id = sa.group_id
JOIN student_group sg ON sg.group_id = sa.group_id
WHERE sa.avg_student_grade > ga.avg_group_grade
ORDER BY sg.name, sa.avg_student_grade DESC, sa.full_name;
