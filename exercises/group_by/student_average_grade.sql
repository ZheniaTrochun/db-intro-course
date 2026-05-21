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
WITH student_grades AS (
    SELECT 
        s.student_id,
        s.group_id,
        p.first_name || ' ' || p.last_name AS full_name,
        AVG(e.grade) AS raw_student_grade
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, s.group_id, p.first_name, p.last_name
)
SELECT 
    sg.student_id,
    sg.full_name,
    ROUND(sg.raw_student_grade, 2)::float AS avg_student_grade,
    g.name AS group_name,
    ROUND(AVG(sg.raw_student_grade) OVER (PARTITION BY sg.group_id), 2)::float AS avg_group_grade
FROM student_grades sg
JOIN student_group g ON sg.group_id = g.group_id
ORDER BY 
    group_name,
    full_name,
    student_id;