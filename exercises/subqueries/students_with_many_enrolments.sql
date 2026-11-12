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
WITH avg_courses AS (
    SELECT
        DISTINCT ROUND (AVG (COUNT (*)) OVER (), 2) AS avg_course_number
    FROM student s
        JOIN enrolment e USING (student_id)
    GROUP BY s.student_id
)
SELECT
    s.student_id AS student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    COUNT (*) AS course_number,
    avg_c.avg_course_number AS avg_number
FROM student s
    JOIN person p USING (person_id)
    JOIN enrolment e USING (student_id)
    CROSS JOIN avg_courses avg_c
GROUP BY s.student_id, p.first_name, p.last_name, avg_c.avg_course_number
HAVING COUNT(*) > avg_c.avg_course_number
ORDER BY course_number DESC, full_name, student_id