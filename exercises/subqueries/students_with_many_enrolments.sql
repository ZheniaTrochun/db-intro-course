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

-- IO-45 Bondarchuk Mykhailo
-- Знайти студентів, які записані на більше курсів, ніж в середньому

WITH StudentCourseCount AS (

    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, p.first_name, p.last_name
),
GlobalAvg AS (

    SELECT AVG(course_number) AS avg_number
    FROM StudentCourseCount
)
SELECT
    student_id,
    full_name,
    CAST(course_number AS BIGINT) AS course_number,

    CAST(ROUND((SELECT avg_number FROM GlobalAvg)::numeric, 2) AS DOUBLE PRECISION) AS avg_number
FROM StudentCourseCount
WHERE course_number > (SELECT avg_number FROM GlobalAvg)
ORDER BY
    course_number DESC,
    full_name ASC;