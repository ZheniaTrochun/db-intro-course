-- порахувати успішність студентів залежно від року навчання
SELECT c.student_year, ROUND(AVG(e.grade), 1) AS average_score
FROM enrolment e
JOIN course c ON e.course_id = c.course_id
WHERE e.grade IS NOT NULL
GROUP BY c.student_year
ORDER BY c.student_year
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
SELECT s.student_id, s.name, s.surname, 
ROUND(AVG(e.grade), 1) AS personal_average
FROM student s
JOIN enrolment e ON s.student_id = e.student_id
WHERE e.grade IS NOT NULL
GROUP BY s.student_id, s.name, s.surname
ORDER BY personal_average
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
SELECT c.student_year,
COUNT(DISTINCT c.course_id) AS total_courses,
COUNT(e.student_id) AS total_enrolments,
COUNT(e.grade) AS students_with_grades
FROM course c
LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year
