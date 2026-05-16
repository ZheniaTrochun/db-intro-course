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
        student_id, 
        ROUND(AVG(grade)::numeric, 2) AS avg_student_grade
    FROM enrolment
    WHERE grade IS NOT NULL
    GROUP BY student_id
),
group_avg AS (
    SELECT 
        s.group_id, 
        ROUND(AVG(e.grade)::numeric, 2) AS avg_group_grade
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)
SELECT 
    s.student_id,
    pe.first_name || ' ' || pe.last_name AS full_name,
    sg.name AS group_name,
    sa.avg_student_grade,
    ga.avg_group_grade
FROM student s
JOIN person pe ON s.person_id = pe.person_id
JOIN student_group sg ON s.group_id = sg.group_id
JOIN student_avg sa ON s.student_id = sa.student_id
JOIN group_avg ga ON s.group_id = ga.group_id
WHERE sa.avg_student_grade > ga.avg_group_grade
ORDER BY 
    group_name, 
    sa.avg_student_grade DESC, 
    full_name;