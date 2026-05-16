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
WITH student_avg AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        sg.name AS group_name,
        AVG(e.grade) AS avg_student
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN student_group sg ON s.group_id = sg.group_id
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id, sg.name
),
group_avg AS (
    SELECT 
        s.group_id,
        AVG(e.grade) AS avg_group
    FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)
SELECT 
    sa.student_id,
    sa.full_name,
    sa.group_name,
    ROUND(sa.avg_student, 2) AS avg_student_grade,
    ROUND(ga.avg_group, 2) AS avg_group_grade
FROM student_avg sa
JOIN group_avg ga ON sa.group_id = ga.group_id
WHERE sa.avg_student > ga.avg_group
ORDER BY 
    group_name ASC, 
    avg_student_grade DESC, 
    full_name ASC;