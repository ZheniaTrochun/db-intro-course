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
        p.first_name || ' ' || p.last_name as full_name,
        sg.name as group_name,
        AVG(e.grade) as avg_student_no_rounded_grade
    FROM student as s
    JOIN person as p ON s.person_id = p.person_id
    JOIN student_group as sg ON s.group_id = sg.group_id
    LEFT JOIN enrolment as e ON e.student_id = s.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id, sg.name
)

SELECT 
    sa.student_id, 
    sa.full_name, 
    ROUND(sa.avg_student_no_rounded_grade, 2) as avg_student_grade,
    sa.group_name, 
    ROUND(AVG(sa.avg_student_no_rounded_grade) OVER (PARTITION BY sa.group_name), 2) as avg_group_grade
FROM student_avg as sa
ORDER BY sa.group_name, sa.full_name;