-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
WITH RECURSIVE course_path AS (
SELECT course_id, "name", 1 AS semester
FROM course
UNION ALL
SELECT cp.course_id, c.name, cp_path.semester + 1
FROM course_prerequisite cp
JOIN course_path cp_path ON cp.prerequisite_course_id = cp_path.course_id
JOIN course c ON cp.course_id = c.course_id )
SELECT "name", MAX(semester) AS min_semester
FROM course_path
GROUP BY "name"
ORDER BY min_semester, "name"
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
WITH student_stats AS (
SELECT student_id, COUNT(course_id) as course_count
FROM enrolment
GROUP BY student_id )
SELECT s.name,ss.course_count
FROM student s
JOIN student_stats ss ON s.student_id = ss.student_id
WHERE ss.course_count > (SELECT AVG(course_count) FROM student_stats)
ORDER BY ss.course_count DESC
-- Знайти топ-3 студенти у кожному курсі за отриманими балами
SELECT course_name, student_name, surname, grade, student_rank
FROM (SELECT 
c.name AS course_name,
s.name AS student_name,
s.surname,
e.grade,
DENSE_RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade DESC) as student_rank
FROM enrolment e
JOIN course c ON e.course_id = c.course_id
JOIN student s ON e.student_id = s.student_id
WHERE e.grade IS NOT NULL) AS ranked_list
WHERE student_rank <= 3
ORDER BY course_name, student_rank
