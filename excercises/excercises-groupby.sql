-- порахувати успішність студентів залежно від року навчання
SELECT 
    c.student_year AS year_of_study, 
    COALESCE(ROUND(AVG(e.grade), 2), 0) AS average_grade
FROM course c
LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year;

-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
WITH student_stats AS (
    SELECT 
        student_id, 
        AVG(grade) AS student_avg_grade
    FROM enrolment
    WHERE grade IS NOT NULL
    GROUP BY student_id
),
group_stats AS (
    SELECT 
        s.group_id, 
        AVG(e.grade) AS group_avg_grade
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)
SELECT 
    s.name || ' ' || s.surname AS student_name,
    sg.name AS group_name,
    ROUND(ss.student_avg_grade, 1) AS my_avg,
    ROUND(gs.group_avg_grade, 1) AS group_avg,
    ROUND(ss.student_avg_grade - gs.group_avg_grade, 1) AS diff
FROM student s
JOIN student_group sg ON s.group_id = sg.group_id
LEFT JOIN student_stats ss ON s.student_id = ss.student_id
LEFT JOIN group_stats gs ON s.group_id = gs.group_id
ORDER BY sg.name, s.surname;

-- порахувати статистику записів на курси для кожного року навчання:
SELECT 
    c.student_year,
    COUNT(DISTINCT c.course_id) AS courses_count,
    COUNT(e.student_id) AS total_enrollments,
    COUNT(e.student_id) FILTER (WHERE e.grade IS NOT NULL) AS graded_students
FROM course c
LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year;
