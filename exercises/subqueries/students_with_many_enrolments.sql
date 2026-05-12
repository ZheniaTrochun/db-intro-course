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

WITH StudentCourseCount AS (
SELECT s.student_id,
CONCAT_WS(' ', p.first_name, p.last_name) AS full_name,
COUNT(e.course_id) AS course_number,
AVG(COUNT(e.course_id)) OVER () AS raw_avg_number
FROM student s
JOIN person p USING (person_id)
JOIN enrolment e USING (student_id)
GROUP BY s.student_id, p.first_name, p.last_name
)
SELECT student_id, full_name, course_number,
ROUND(raw_avg_number, 2) AS avg_number
FROM StudentCourseCount
WHERE course_number > raw_avg_number
ORDER BY course_number DESC, full_name ASC, student_id ASC;