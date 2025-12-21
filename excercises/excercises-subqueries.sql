-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись

SELECT 
    c.name AS course,
    GREATEST(
        (c.student_year - 1) * 2 + 1,
        (SELECT MAX(parent.student_year) 
         FROM course_prerequisite cp
         JOIN course parent ON cp.prerequisite_course_id = parent.course_id
         WHERE cp.course_id = c.course_id
        ) * 2 + 1
    ) AS min_semester
FROM course c
ORDER BY min_semester, c.name;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти

SELECT 
    s.name || ' ' || s.surname AS student,
    COUNT(e.course_id) AS amount_of_courses
FROM student s
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name, s.surname
HAVING COUNT(e.course_id) > (
    SELECT AVG(course_count)
    FROM (
        SELECT COUNT(course_id) AS course_count
        FROM enrolment
        GROUP BY student_id
    ) AS subquery_counts
);

-- Знайти топ-3 студенти у кожному курсі за отриманими балами

SELECT 
    course_name,
    student_name,
    grade,
    rank_in_course
FROM (
    SELECT 
        c.name AS course_name,
        s.name || ' ' || s.surname AS student_name,
        e.grade,
        DENSE_RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade DESC) as rank_in_course
    FROM enrolment e
    JOIN course c ON e.course_id = c.course_id
    JOIN student s ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
) AS ranked_students
WHERE rank_in_course <= 3
ORDER BY course_name, rank_in_course;