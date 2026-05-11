-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента

-- Рішення:
WITH student_course_count AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM student s
    JOIN person p ON p.person_id = s.person_id
    LEFT JOIN enrolment e ON e.student_id = s.student_id
    GROUP BY s.student_id, p.first_name, p.last_name
),
avg_value AS (
    SELECT AVG(course_number) AS avg_number
    FROM student_course_count
)
SELECT 
    scc.student_id,
    scc.full_name,
    scc.course_number,
    ROUND(av.avg_number, 2) AS avg_number
FROM student_course_count scc
CROSS JOIN avg_value av
WHERE scc.course_number > av.avg_number
ORDER BY 
    scc.course_number DESC,
    scc.full_name;