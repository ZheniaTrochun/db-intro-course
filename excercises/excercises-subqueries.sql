-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
WITH RECURSIVE course_depth AS (
	SELECT course_id, 1 AS depth_level
	FROM course c
	WHERE NOT EXISTS(SELECT 1 FROM course_prerequisite cp WHERE cp.course_id = c.course_id)
	UNION ALL
	SELECT cp.course_id as course_id, cd.depth_level + 1 AS depth_level 
	FROM course_prerequisite cp 
	INNER JOIN course_depth cd ON cd.course_id = cp.prerequisite_course_id
)
SELECT c.name, MAX(cd.depth_level) as min_semestr 
FROM course c 
INNER JOIN course_depth cd USING(course_id)
GROUP BY course_id, c.name
ORDER BY min_semestr DESC;
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти

WITH student_course_count AS (
	SELECT s.student_id, s.name || ' ' || s.surname as full_name, COUNT(*) AS course_count
	FROM student s
	INNER JOIN enrolment e USING(student_id)
	GROUP BY s.student_id, s.name, s.surname
),
	avg_course_count AS (
	SELECT AVG(course_count) as avg_course_count -- Прибрав ROUND для точності порівняння, бо наприклад 2.99 округлиться до 3 і студент з 3 курсами не буде включений, а повинен
	FROM student_course_count
)
SELECT *
FROM student_course_count sc, avg_course_count acc
WHERE course_count > acc.avg_course_count
ORDER BY sc.course_count DESC;
-- Знайти топ-3 студенти у кожному курсі за отриманими балами
WITH student_course_grade AS (
	SELECT s.student_id, 
	s.name || ' ' || s.surname as full_name, 
	c.course_id, 
	c.name, 
	e.grade,
	DENSE_RANK() OVER(PARTITION BY c.course_id ORDER BY e.grade DESC NULLS LAST) AS rank_in_course
	FROM student s
	INNER JOIN enrolment e USING(student_id)
	INNER JOIN course c USING(course_id)
)
SELECT * FROM student_course_grade scg
WHERE rank_in_course <= 3 
ORDER BY scg.name, rank_in_course ASC;


