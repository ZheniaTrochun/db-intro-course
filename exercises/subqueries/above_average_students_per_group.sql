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
WITH student_avgs AS (
    SELECT 
        s.id AS student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        sg.name AS group_name,
        ROUND(AVG(e.grade), 2) AS avg_student_grade
    FROM student s
    JOIN person p ON s.person_id = p.id
    JOIN student_group sg ON s.group_id = sg.id
    JOIN enrolment e ON s.id = e.student_id
    GROUP BY s.id, p.first_name, p.last_name, s.group_id, sg.name
),
group_avgs AS (
    
    SELECT 
        s.group_id,
        ROUND(AVG(e.grade), 2) AS avg_group_grade
    FROM student s
    JOIN enrolment e ON s.id = e.student_id
    GROUP BY s.group_id
)
SELECT 
    sa.student_id,
    sa.full_name,
    sa.group_name,
    sa.avg_student_grade,
    ga.avg_group_grade
FROM student_avgs sa
JOIN group_avgs ga ON sa.group_id = ga.group_id
WHERE sa.avg_student_grade > ga.avg_group_grade
ORDER BY 
    sa.group_name ASC, 
    sa.avg_student_grade DESC, 
    sa.full_name ASC;
