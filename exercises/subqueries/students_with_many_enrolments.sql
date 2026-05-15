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
SELECT s.student_id, CONCAT(s.first_name, ' ', s.last_name) AS full_name, COUNT(e.course_id) AS course_number
FROM student s
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.first_name, s.last_name
)
SELECT student_id, full_name, course_number, ROUND(AVG(course_number) OVER (), 2) AS avg_number FROM student_courses
WHERE course_number > (
SELECT AVG(course_number) FROM student_courses
)
ORDER BY course_number DESC, full_name ASC, student_id ASC;
