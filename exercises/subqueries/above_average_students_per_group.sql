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
        s.group_id,
        p.first_name || ' ' || p.last_name AS full_name,
        AVG(e.grade) AS raw_student_grade
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
group_avg AS (
    SELECT 
        s.group_id,
        AVG(e.grade) AS raw_group_grade
    FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)
SELECT 
    sa.student_id,
    sa.full_name,
    sg.name AS group_name,
    ROUND(sa.raw_student_grade, 2)::float AS avg_student_grade,
    ROUND(ga.raw_group_grade, 2)::float AS avg_group_grade
FROM student_avg sa
JOIN group_avg ga ON sa.group_id = ga.group_id
JOIN student_group sg ON sa.group_id = sg.group_id
WHERE ROUND(sa.raw_student_grade, 2) > ROUND(ga.raw_group_grade, 2) -- Округлене порівняння
ORDER BY 
    group_name ASC, 
    sa.raw_student_grade DESC, 
    sa.full_name ASC,
    sa.student_id ASC