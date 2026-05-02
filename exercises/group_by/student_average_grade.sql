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
        ROUND(AVG(e.grade), 2) AS avg_student_grade
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
group_avg AS (
    SELECT 
        s.group_id,
        sg.name AS group_name,
        ROUND(AVG(e.grade), 2) AS avg_group_grade
    FROM student s
    JOIN student_group sg ON s.group_id = sg.group_id
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.group_id, sg.name
)
SELECT 
    sa.student_id,
    sa.full_name,
    sa.avg_student_grade,
    ga.group_name,
    ga.avg_group_grade
FROM student_avg sa
JOIN group_avg ga ON sa.group_id = ga.group_id
ORDER BY 
    ga.group_name ASC, 
    sa.full_name ASC;