--Всі запити та дані використані з файлів create-campus-tables.sql, insert-data.sql, subqueries.sql
-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
WITH RECURSIVE course_sem AS (
   SELECT course_id, 1 AS sem FROM course
   WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)
   UNION ALL
   SELECT cp.course_id, t.sem + 1
   FROM course_prerequisite cp
   JOIN course c ON c.course_id = cp.course_id
   JOIN course_sem t ON t.course_id = cp.prerequisite_course_id
)
SELECT name, MAX(sem) AS min_sem 
FROM course_sem 
JOIN course ON course_sem.course_id = course.course_id
GROUP BY name 
ORDER BY min_sem;
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
WITH counts AS (
  SELECT student_id, COUNT(*) AS count_val
  FROM enrolment GROUP BY student_id
)
SELECT * FROM student s
INNER JOIN counts c ON s.student_id = c.student_id
WHERE c.count_val > (SELECT AVG(count_val) FROM counts);
-- Знайти топ-3 студенти у кожному курсі за отриманими балами
WITH rank AS (
   SELECT c.name AS course, surname, grade,
   ROW_NUMBER() OVER (PARTITION BY e.course_id ORDER BY grade DESC) AS row_number
   FROM enrolment e
   JOIN student s USING(student_id)
   JOIN course c USING(course_id)
   WHERE grade IS NOT NULL AND grade > 0
)
SELECT * FROM rank WHERE row_number <= 3;
