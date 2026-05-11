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
WITH StudentAverages AS (
    SELECT 
        e.student_id, 
        s.group_id, 
        AVG(e.grade) AS s_avg
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY e.student_id, s.group_id
),
GroupAverages AS (
    SELECT 
        group_id, 
        AVG(s_avg) AS g_avg
    FROM StudentAverages
    GROUP BY group_id
)
SELECT 
    sa.student_id, 
    p.first_name || ' ' || p.last_name AS full_name, 
    sg.name AS group_name,
    ROUND(sa.s_avg::numeric, 2) AS avg_student_grade,
    ROUND(ga.g_avg::numeric, 2) AS avg_group_grade
FROM StudentAverages sa
JOIN GroupAverages  ga ON sa.group_id = ga.group_id
JOIN student       s  ON sa.student_id = s.student_id
JOIN person        p  ON s.person_id = p.person_id
JOIN student_group sg ON sa.group_id = sg.group_id
WHERE sa.s_avg > ga.g_avg
ORDER BY 
    group_name, 
    avg_student_grade DESC, 
    sa.student_id;
