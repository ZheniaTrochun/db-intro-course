-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента, потім за ідентифікатор студента

-- Рішення:
WITH student_counts AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM student s
    JOIN person p ON p.person_id = s.person_id
    LEFT JOIN enrolment e ON e.student_id = s.student_id
    GROUP BY s.student_id, p.first_name, p.last_name
),
counts_with_avg AS (
    SELECT 
        student_id, 
        full_name, 
        course_number,
        ROUND(AVG(course_number) OVER (), 2)::float AS avg_number
    FROM student_counts
)
SELECT 
    student_id, 
    full_name, 
    course_number, 
    avg_number
FROM counts_with_avg
WHERE course_number > avg_number
ORDER BY 
    course_number DESC,
    full_name ASC,
    student_id ASC;