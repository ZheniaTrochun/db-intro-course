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
WITH student_enrolments AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, full_name
)
SELECT 
    student_id,
    full_name,
    course_number,
    (SELECT ROUND(AVG(course_number), 2) FROM student_enrolments) AS avg_number
FROM student_enrolments
WHERE course_number > (SELECT AVG(course_number) FROM student_enrolments)
ORDER BY course_number DESC, full_name;