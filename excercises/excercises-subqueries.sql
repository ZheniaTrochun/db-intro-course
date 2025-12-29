-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись

SELECT
    c.name AS course,
    (
        SELECT MAX(year_val) * 2 - 1
        FROM (
                 SELECT c.student_year AS year_val
                 UNION ALL
                 SELECT p.student_year
                 FROM course_prerequisite cp
                          JOIN course p ON cp.prerequisite_course_id = p.course_id
                 WHERE cp.course_id = c.course_id
             ) sub
    ) AS min_semester
FROM course c
ORDER BY min_semester, course;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти

SELECT
    s.name,
    s.surname,
    COUNT(e.course_id) AS courses_count
FROM student s
         JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name, s.surname
HAVING COUNT(e.course_id) >
       (
           SELECT AVG(course_count)
           FROM (
                    SELECT COUNT(course_id) AS course_count
                    FROM enrolment
                    GROUP BY student_id
                ) sub
       )
ORDER BY courses_count DESC;

-- Знайти топ-3 студенти у кожному курсі за отриманими балами

SELECT
    course,
    surname,
    grade,
    position
FROM (
         SELECT
             c.name AS course,
             s.surname,
             e.grade,
             (
                 SELECT COUNT(*)
                 FROM enrolment e2
                 WHERE e2.course_id = e.course_id
                   AND e2.grade > e.grade
             ) + 1 AS position
         FROM enrolment e
                  JOIN student s ON e.student_id = s.student_id
                  JOIN course c ON e.course_id = c.course_id
         WHERE e.grade IS NOT NULL
     ) t
WHERE position <= 3
ORDER BY course, position;
