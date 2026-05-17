-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:


--ІО-41 Кореняко Антон

WITH student_grades AS (
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        sg.group_id,
        sg.name AS group_name,
        ROUND(AVG(e.grade)::numeric, 2) AS avg_student_grade
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN student_group sg ON s.group_id = sg.group_id
    LEFT JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, sg.group_id, sg.name
),
group_grades AS (
    SELECT
        group_id,
        ROUND(AVG(avg_student_grade)::numeric, 2) AS avg_group_grade
    FROM student_grades
    GROUP BY group_id
)
SELECT
    sg.student_id,
    sg.full_name,
    CAST(sg.avg_student_grade AS DOUBLE PRECISION) AS avg_student_grade,
    sg.group_name,
    CAST(gg.avg_group_grade AS DOUBLE PRECISION) AS avg_group_grade
FROM student_grades sg
JOIN group_grades gg ON sg.group_id = gg.group_id
ORDER BY
    sg.group_name ASC,
    sg.full_name ASC;
