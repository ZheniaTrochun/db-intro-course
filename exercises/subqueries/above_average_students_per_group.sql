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
WITH avg_st_grade AS ( 
    SELECT 
        s.student_id, 
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        AVG(e.grade) as avg_s_grade,
        s.group_id
    FROM student s
    INNER JOIN person p USING(person_id)
    INNER JOIN enrolment e USING(student_id)
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
avg_gr_grade AS ( 
    SELECT 
        s.group_id, 
        AVG(e.grade) as avg_g_grade
    FROM student s
    INNER JOIN enrolment e USING(student_id)
    GROUP BY s.group_id
)
SELECT 
    asg.student_id, 
    asg.full_name, 
    sg.name AS group_name,
    ROUND(asg.avg_s_grade, 2) AS avg_student_grade,
    ROUND(agg.avg_g_grade, 2) AS avg_group_grade
FROM avg_st_grade asg
INNER JOIN student_group sg ON asg.group_id = sg.group_id
INNER JOIN avg_gr_grade agg ON asg.group_id = agg.group_id
WHERE asg.avg_s_grade > agg.avg_g_grade
ORDER BY 
    group_name ASC, 
    avg_student_grade DESC, 
    asg.student_id ASC; -- Додано для стабільного сортування