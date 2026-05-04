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
        student_id,
        COUNT(course_id) AS course_number
    FROM enrolment
    GROUP BY student_id
),
global_avg AS (
    SELECT
        AVG(course_number) AS avg_number
    FROM student_course_count
)
SELECT
    scc.student_id,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    scc.course_number,
    CAST(ROUND(CAST(ga.avg_number AS numeric), 2) AS FLOAT) AS avg_number
FROM student_course_count scc
CROSS JOIN global_avg ga
JOIN student s ON scc.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
WHERE scc.course_number > ga.avg_number
ORDER BY
    scc.course_number DESC,
    full_name ASC;