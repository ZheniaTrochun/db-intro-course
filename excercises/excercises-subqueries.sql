-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
WITH RECURSIVE course_dependencies AS (
    SELECT course_id, c.student_year::INTEGER as min_semestr 
    FROM course c
    WHERE NOT EXISTS (SELECT 1 FROM course_prerequisite p WHERE p.course_id = c.course_id)
    UNION ALL
    SELECT p.course_id as course_id, GREATEST((SELECT c.student_year FROM course c WHERE c.course_id = p.course_id),(cd.min_semestr+1)) as min_semestr
    FROM course_prerequisite p
             INNER JOIN course_dependencies cd ON p.prerequisite_course_id = cd.course_id
)
SELECT c.course_id, c.name, MAX(cd.min_semestr) AS real_min_semester
FROM course c INNER JOIN course_dependencies cd USING (course_id)
GROUP BY c.course_id, c.name;
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти

WITH student_course_count AS (
	SELECT s.student_id, s.name || ' ' || s.surname as full_name, COUNT(*) AS course_count
	FROM student s
	INNER JOIN enrolment e USING(student_id)
	GROUP BY s.student_id, s.name, s.surname
),
	avg_course_count AS (
	SELECT ROUND(AVG(course_count),1) as avg_course_count
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
	DENSE_RANK() OVER(PARTITION BY c.course_id ORDER BY e.grade DESC) AS rank_in_course
	FROM student s
	INNER JOIN enrolment e USING(student_id)
	INNER JOIN course c USING(course_id)
)
SELECT * FROM student_course_grade scg
WHERE rank_in_course <= 3 
ORDER BY scg.name, rank_in_course ASC;
