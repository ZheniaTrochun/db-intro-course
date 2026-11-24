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
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента, потім за ідентифікатором студента
-- Рішення:
WITH student_avg AS (
    SELECT
        s.student_id AS student_id,
        sg.group_id AS group_id,
        AVG(e.grade) AS avg_student_grade
    FROM student AS s
    JOIN student_group_assignment AS sga
        ON sga.student_id = s.student_id
    JOIN student_group AS sg
        ON sg.group_id = sga.group_id
    JOIN enrolment AS e
        ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, sg.group_id
),
group_avg AS (
    SELECT
        sg.group_id AS group_id,
        AVG(e.grade) AS avg_group_grade
    FROM student_group AS sg
    JOIN student_group_assignment AS sga
        ON sga.group_id = sg.group_id
    JOIN student AS s
        ON s.student_id = sga.student_id
    JOIN enrolment AS e
        ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY sg.group_id
)
SELECT
    sa.student_id AS student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sg.group_name AS group_name,
    ROUND(sa.avg_student_grade, 2) AS avg_student_grade,
    ROUND(ga.avg_group_grade, 2) AS avg_group_grade
FROM student_avg AS sa
JOIN group_avg AS ga
    ON ga.group_id = sa.group_id
JOIN student AS s
    ON s.student_id = sa.student_id
JOIN person AS p
    ON p.person_id = s.person_id
JOIN student_group AS sg
    ON sg.group_id = sa.group_id
WHERE ROUND(sa.avg_student_grade, 2) > ROUND(ga.avg_group_grade, 2)
ORDER BY
    sg.group_name ASC,
    ROUND(sa.avg_student_grade, 2) DESC,
    full_name ASC,
    sa.student_id ASC;
