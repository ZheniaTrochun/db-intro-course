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
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:

WITH student_avg AS (
    SELECT
        e.student_id,
        AVG(e.grade) AS avg_grade
    FROM enrolment e
    GROUP BY e.student_id
),	
group_avg AS (
    SELECT
        sga.group_id,
        AVG(e.grade) AS avg_group_grade
    FROM student_group_assignment sga
    INNER JOIN enrolment e ON e.student_id = sga.student_id
    GROUP BY sga.group_id
)
SELECT
    sa.student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sg.group_name,
    ROUND(sa.avg_grade, 2) AS avg_student_grade,
    ROUND(ga.avg_group_grade, 2) AS avg_group_grade
FROM student_avg sa
INNER JOIN student_group_assignment sga ON sa.student_id = sga.student_id
INNER JOIN group_avg ga ON ga.group_id = sga.group_id
INNER JOIN student_group sg ON sg.group_id = sga.group_id
INNER JOIN student s ON sa.student_id = s.student_id
INNER JOIN person p ON s.person_id = p.person_id
WHERE ROUND(sa.avg_grade, 2) > ROUND(ga.avg_group_grade, 2)
ORDER BY sg.group_name, avg_student_grade DESC, full_name, sa.student_id;