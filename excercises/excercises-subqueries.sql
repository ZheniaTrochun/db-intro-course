-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись

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
WITH avg_student_grade_for_course AS (
    SELECT student_id,
           course_id,
           avg(grade) AS avg_student_grade
    FROM enrolment
        INNER JOIN student USING (student_id)
        INNER JOIN course USING (course_id)
    WHERE grade IS NOT NULL
    GROUP BY course_id, student_id
    ORDER BY course_id, avg(grade)
),
    student_ranks AS (
    SELECT
        c.name AS course_name,
        s.name || ' ' || s.surname AS student_full_name,
        avg_student_grade,
        ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY avg_student_grade DESC) AS rank
    FROM student s
        INNER JOIN avg_student_grade_for_course USING (student_id)
        INNER JOIN course c USING (course_id)
    ORDER BY course_id, rank
)
SELECT *
FROM student_ranks
WHERE rank <= 3;
