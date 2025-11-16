-- SELECT
--     s.student_id,
--     s.name,
--     s.surname,
--     s.group_id AS "Group",
--     ROUND(AVG(e.grade), 2) AS "Student Avg Grade",
--     ROUND(AVG(AVG(e.grade)) OVER (PARTITION BY s.group_id), 2) AS "Group Avg Grade",
--     ROUND(AVG(e.grade) - AVG(AVG(e.grade)) OVER (PARTITION BY s.group_id), 2) AS "Difference from Group Avg"
-- FROM student s
-- JOIN enrolment e ON s.student_id = e.student_id
-- WHERE e.grade IS NOT NULL
-- GROUP BY s.student_id, s.name, s.surname, s.group_id
-- ORDER BY s.group_id, "Difference from Group Avg" DESC;

-- -----------

-- SELECT s.group_id AS "Study Group", ROUND(AVG(e.grade), 2) AS "Average Grade"
-- FROM student s
-- JOIN enrolment e ON s.student_id = e.student_id
-- WHERE e.grade IS NOT NULL
-- GROUP BY s.group_id
-- ORDER BY s.group_id;


-- ----

-- SELECT course_id, name, student_year AS "Minimum Study Year"
-- FROM course
-- ORDER BY student_year, course_id;

 -- ----


-- SELECT s.group_id AS "Study Group", 
    -- COUNT(DISTINCT e.course_id) AS "Total Courses", 
    -- COUNT(e.student_id) AS "Total Enrollments", 
    -- COUNT(DISTINCT CASE WHEN e.grade IS NOT NULL THEN s.student_id END) AS "Students with Grades"
-- FROM student s
-- JOIN enrolment e ON s.student_id = e.student_id
-- GROUP BY s.group_id
-- ORDER BY s.group_id;

-- ----


-- SELECT c.name AS course_name, s.name AS student_name, s.surname AS student_surname, ranked.grade
-- FROM
--     (
--         SELECT
--             e.course_id,
--             e.student_id,
--             e.grade,
--             RANK() OVER (PARTITION BY e.course_id ORDER BY e.grade DESC) AS rank_in_course
--         FROM
--             enrolment e
--     ) ranked
-- JOIN student s ON s.student_id = ranked.student_id
-- JOIN course c ON c.course_id = ranked.course_id
-- WHERE ranked.rank_in_course <= 3
-- ORDER BY c.name, ranked.rank_in_course, ranked.grade DESC;

-- ----

-- SELECT course_id, name, student_year AS "Study Year", (course.student_year - 1) * 2 + 1 AS "Minimum Semester Calculation"
-- FROM course
-- ORDER BY "Minimum Semester Calculation", course_id;