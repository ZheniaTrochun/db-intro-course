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
