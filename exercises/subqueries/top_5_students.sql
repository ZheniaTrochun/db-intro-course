-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank) - за балом, іменем студента та ідентифікатором студента
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
WITH StudentCourseCounts AS (
SELECT s.student_id, p.first_name || ' ' || p.last_name AS full_name,
COUNT(e.course_id) AS course_number
FROM student s
JOIN person p    ON p.person_id = s.person_id
JOIN enrolment e ON e.student_id = s.student_id
GROUP BY s.student_id, p.first_name, p.last_name
),
AverageStats AS (
SELECT student_id, full_name, course_number,
ROUND(AVG(course_number) OVER (), 2) AS avg_number
FROM StudentCourseCounts
)
SELECT student_id, full_name, course_number, avg_number
FROM AverageStats
WHERE course_number > avg_number
ORDER BY course_number DESC, full_name,student_id; 
