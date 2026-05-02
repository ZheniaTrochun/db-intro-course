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
WITH student_avg AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        ROUND(AVG(e.grade)::numeric, 2) AS avg_student_grade
    FROM student s
    JOIN person p ON p.person_id = s.person_id
    LEFT JOIN enrolment e ON e.student_id = s.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
group_avg AS (
    SELECT 
        s.group_id,
        ROUND(AVG(student_avg_grade)::numeric, 2) AS avg_group_grade
    FROM (
        SELECT 
            s.group_id,
            AVG(e.grade) AS student_avg_grade
        FROM student s
        JOIN enrolment e ON e.student_id = s.student_id
        GROUP BY s.student_id, s.group_id
    ) s
    GROUP BY s.group_id
)
SELECT 
    sa.student_id,
    sa.full_name,
    sa.avg_student_grade,
    sg.name AS group_name,
    ga.avg_group_grade
FROM student_avg sa
JOIN group_avg ga ON ga.group_id = sa.group_id
JOIN student_group sg ON sg.group_id = sa.group_id
ORDER BY sg.name ASC, sa.full_name ASC;