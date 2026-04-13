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
WITH student_course_counts AS (
    SELECT 
        s.id AS student_id,
        s.first_name || ' ' || s.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM students s
    JOIN enrollments e ON s.id = e.student_id
    GROUP BY s.id, s.first_name, s.last_name
)
SELECT 
    student_id,
    full_name,
    course_number,
    (SELECT ROUND(AVG(course_number), 2) FROM student_course_counts) AS avg_number
FROM student_course_counts
WHERE course_number > (SELECT AVG(course_number) FROM student_course_counts)
ORDER BY course_number DESC, full_name ASC;
