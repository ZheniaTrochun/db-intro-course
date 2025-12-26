-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
WITH RECURSIVE course_semester AS (
    SELECT 
        c.course_id, 
        c.name, 
        1 AS min_semester
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1 FROM course_prerequisite cp WHERE cp.course_id = c.course_id
    )
    UNION ALL
    SELECT 
        cp.course_id, 
        c.name, 
        cs.min_semester + 1
    FROM course_prerequisite cp
    JOIN course_semester cs ON cp.prerequisite_course_id = cs.course_id
    JOIN course c ON cp.course_id = c.course_id
)
SELECT course_id, name, MAX(min_semester) as min_semester
FROM course_semester
GROUP BY course_id, name
ORDER BY min_semester, name;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
WITH student_counts AS (
    SELECT student_id, COUNT(course_id) AS c_count
    FROM enrolment
    GROUP BY student_id
),
avg_val AS (
    SELECT AVG(c_count) AS global_avg FROM student_counts
)
SELECT 
    s.name, 
    s.surname, 
    sc.c_count, 
    ROUND(acc.global_avg, 2) as avg_display
FROM student s
JOIN student_counts sc USING(student_id)
CROSS JOIN avg_val acc
WHERE sc.c_count > acc.global_avg
ORDER BY sc.c_count DESC;

-- Знайти топ-3 студенти у кожному курсі за отриманими балами
WITH ranked_students AS (
    SELECT 
        c.name AS course_name,
        s.name AS student_name,
        s.surname AS student_surname,
        e.grade,
        DENSE_RANK() OVER (
            PARTITION BY c.course_id 
            ORDER BY e.grade DESC NULLS LAST
        ) AS rank_in_course
    FROM enrolment e
    JOIN student s USING(student_id)
    JOIN course c USING(course_id)
    WHERE e.grade IS NOT NULL
)
SELECT * FROM ranked_students
WHERE rank_in_course <= 3
ORDER BY course_name, rank_in_course;