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
WITH student_avgs AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        sg.name AS group_name,
        AVG(e.grade) AS avg_student_grade
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN student_group sg ON s.group_id = sg.group_id
    LEFT JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id, sg.name
),
group_avgs AS (
    SELECT 
        group_id,
        AVG(avg_student_grade) AS avg_group_grade
    FROM student_avgs
    GROUP BY group_id
)
SELECT 
    sa.student_id,
    sa.full_name,
    ROUND(sa.avg_student_grade, 2) AS avg_student_grade,
    sa.group_name,
    ROUND(ga.avg_group_grade, 2) AS avg_group_grade
FROM student_avgs sa
JOIN group_avgs ga ON sa.group_id = ga.group_id
ORDER BY 
    sa.group_name ASC, 
    sa.full_name ASC;
