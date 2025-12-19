-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти\
WITH enrollment_stats AS (
    SELECT 
        s.student_id,
        s.name,
        s.surname,
        COUNT(e.course_id) AS total_courses
    FROM student s
    LEFT JOIN enrolment e USING(student_id)
    GROUP BY s.student_id, s.name, s.surname
),
average_calculation AS (
    SELECT 
        AVG(total_courses) AS mean_courses
    FROM enrollment_stats
)
SELECT 
    es.student_id,
    es.name,
    es.surname,
    es.total_courses,
    ROUND(ac.mean_courses, 1) AS average_courses
FROM enrollment_stats es
CROSS JOIN average_calculation ac
WHERE es.total_courses > ac.mean_courses
ORDER BY es.student_id
-- Знайти топ-3 студенти у кожному курсі за отриманими балами
WITH course_rankings AS (
    SELECT
        c.course_id,
        c.name AS course_title,
        s.student_id,
        CONCAT(s.surname, ' ', s.name) AS full_name,
        e.grade AS score,
        DENSE_RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade DESC) AS position
    FROM enrolment e
    INNER JOIN student s ON e.student_id = s.student_id
    INNER JOIN course c ON e.course_id = c.course_id
    WHERE e.grade IS NOT NULL
)
SELECT 
    course_title,
    full_name,
    score,
    position
FROM course_rankings
WHERE position <= 3
ORDER BY course_title, position;
