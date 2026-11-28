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

WITH student_courses AS (
    SELECT
        s.student_id,
        COUNT(e.course_id) AS course_number
    FROM student s
	LEFT JOIN enrolment e ON e.student_id = s.student_id
    GROUP BY s.student_id
)
SELECT
    sc.student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sc.course_number,
    ROUND((SELECT AVG(course_number) FROM student_courses), 2) AS avg_number
FROM student_courses sc
INNER JOIN student s ON sc.student_id = s.student_id
INNER JOIN person p ON s.person_id = p.person_id
WHERE sc.course_number > (SELECT AVG(course_number) FROM student_courses)
ORDER BY sc.course_number DESC, full_name, sc.student_id;