-- порахувати успішність студентів залежно від року навчання

SELECT 
    c.student_year AS course_year,
    ROUND(AVG(e.grade), 1) AS average_grade
FROM course c
JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year ASC;

-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі

WITH GroupStats AS (
    SELECT 
        s.group_id,
        AVG(e.grade) as avg_group_grade
    FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.group_id
),

StudentStats AS (
    SELECT 
        s.student_id,
        s.name,
        s.surname,
        s.group_id,
        AVG(e.grade) as avg_student_grade
    FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, s.name, s.surname, s.group_id
)

SELECT 
    ss.name AS "name",
    ss.surname AS "surname",
    sg.name AS "group_name",
    ROUND(ss.avg_student_grade, 1) AS "student_grade",
    ROUND(gs.avg_group_grade, 1) AS "group_grade",
    ROUND(ss.avg_student_grade - gs.avg_group_grade, 1) AS "difference"
FROM StudentStats ss
JOIN GroupStats gs ON ss.group_id = gs.group_id
JOIN student_group sg ON ss.group_id = sg.group_id
ORDER BY sg.name, ss.surname;

-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали

SELECT 
    c.student_year AS year_of_study,
    COUNT(DISTINCT c.course_id) AS amount_of_courses,
    COUNT(e.student_id) AS course_entries_number,
    COUNT(DISTINCT e.student_id) FILTER (WHERE e.grade IS NOT NULL) AS students_with_grades
FROM course c
LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year;