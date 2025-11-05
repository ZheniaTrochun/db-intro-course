-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
WITH RECURSIVE course_dependencies_depth AS (
    SELECT course_id,  1 AS level
    FROM course c
    WHERE NOT EXISTS(SELECT 1 FROM course_prerequisite cp WHERE c.course_id = cp.course_id)
    UNION ALL
    SELECT cp.course_id AS course_id, cdd.level + 1 AS level
    FROM course_prerequisite cp
        INNER JOIN course_dependencies_depth cdd ON cp.prerequisite_course_id = cdd.course_id
)
SELECT course_id,
       c.name,
       MAX(cdd.level) as min_year
FROM course c
    INNER JOIN course_dependencies_depth cdd USING (course_id)
GROUP BY course_id, c.name
ORDER BY course_id;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
WITH student_course_number AS (
    SELECT student_id,
           count(course_id) AS course_number
    FROM enrolment e
    GROUP BY student_id),
     avg_course_number AS (
    SELECT
        round(avg(course_number), 1) AS avg_number
    FROM student_course_number
)
SELECT student_id,
       course_number,
       avg_number
FROM student_course_number
    CROSS JOIN avg_course_number
WHERE course_number > avg_number
ORDER BY course_number DESC;

-- Знайти топ-3 студенти у кожному курсі за отриманими балами
WITH student_ranks AS (
    SELECT
        c.name AS course_name,
        s.name || ' ' || s.surname AS student_full_name,
        grade,
        ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY grade DESC) AS rank
    FROM student s
        INNER JOIN enrolment e USING (student_id)
        INNER JOIN course c USING (course_id)
    WHERE grade IS NOT NULL
)
SELECT *
FROM student_ranks
WHERE rank <= 3
ORDER BY course_name, rank;
