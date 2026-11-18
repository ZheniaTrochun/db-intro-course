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

WITH student_grades
AS (
    SELECT p.first_name || ' ' || p.last_name AS full_name,
           AVG(grade) AS avg_student_grade,
           s.student_id,
           sga.group_id
    FROM student s
    INNER JOIN student_group_assignment sga USING(student_id)
    INNER JOIN enrolment e USING(student_id)
    INNER JOIN person p USING(person_id)
    WHERE e.grade IS NOT NULL
    GROUP BY p.first_name, p.last_name, s.student_id, sga.group_id
), 
group_grades 
AS (
    SELECT 
        sg.group_id,
        sg.group_name,
        AVG(e.grade) AS avg_group_grade
    FROM student_group sg
    INNER JOIN student_group_assignment sga USING(group_id)
    INNER JOIN enrolment e USING(student_id)
    WHERE e.grade IS NOT NULL
    GROUP BY sg.group_id, sg.group_name
)

SELECT student_id,
       full_name,
       group_name,
       ROUND(COALESCE(avg_student_grade, 0), 2)::DOUBLE PRECISION AS avg_student_grade,
       ROUND(COALESCE(avg_group_grade, 0), 2)::DOUBLE PRECISION AS avg_group_grade
FROM student_grades sg
INNER JOIN group_grades ggr USING(group_id)
WHERE ROUND(avg_student_grade, 2) > ROUND(avg_group_grade, 2)
ORDER BY group_name, avg_student_grade DESC, full_name, student_id;