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
WITH student_grades AS (
    SELECT 
        s.id AS student_id,
        s.first_name || ' ' || s.last_name AS full_name,
        s.group_id,
        AVG(e.grade) AS avg_student_grade
    FROM students s
    JOIN enrollments e ON s.id = e.student_id
    GROUP BY s.id, s.first_name, s.last_name, s.group_id
),
group_grades AS (
    SELECT 
        s.group_id,
        g.name AS group_name,
        AVG(e.grade) AS avg_group_grade
    FROM students s
    JOIN groups g ON s.group_id = g.id
    JOIN enrollments e ON s.id = e.student_id
    GROUP BY s.group_id, g.name
)
SELECT 
    sg.student_id,
    sg.full_name,
    gg.group_name,
    ROUND(sg.avg_student_grade, 2) AS avg_student_grade,
    ROUND(gg.avg_group_grade, 2) AS avg_group_grade
FROM student_grades sg
JOIN group_grades gg ON sg.group_id = gg.group_id
WHERE sg.avg_student_grade > gg.avg_group_grade
ORDER BY 
    gg.group_name ASC, 
    avg_student_grade DESC, 
    sg.full_name ASC;
