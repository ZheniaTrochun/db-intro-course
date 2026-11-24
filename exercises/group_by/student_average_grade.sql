-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
WITH student_avg AS (
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        AVG(e.grade) AS avg_student_grade
    FROM student AS s
    JOIN person AS p
        ON p.person_id = s.person_id
    LEFT JOIN enrolment AS e
        ON e.student_id = s.student_id
    GROUP BY
        s.student_id,
        p.first_name,
        p.last_name
),
student_with_group AS (
    SELECT
        sa.student_id,
        sa.full_name,
        sa.avg_student_grade,
        sg.group_id,
        sg.group_name
    FROM student_avg AS sa
    JOIN student_group_assignment AS sga
        ON sga.student_id = sa.student_id
    JOIN student_group AS sg
        ON sg.group_id = sga.group_id
)
SELECT
    student_id,
    full_name,
    ROUND(avg_student_grade, 2) AS avg_student_grade,
    group_name,
    ROUND(AVG(avg_student_grade) OVER (PARTITION BY group_id), 2) AS avg_group_grade
FROM student_with_group
ORDER BY
    group_name ASC,
    full_name ASC,
    student_id ASC;
