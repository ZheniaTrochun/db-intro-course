-- порахувати успішність студентів залежно від року навчання
--
SELECT c.student_year, COALESCE(ROUND(AVG(e.grade),1),0) as average_grade FROM course c
INNER JOIN enrolment e USING(course_id)
GROUP BY c.student_year
ORDER BY average_grade DESC;
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
--
SELECT
    s.name || ' ' || s.surname AS full_name,
    g.name AS group_name,
    ROUND(AVG(e.grade), 1) AS student_avg_grade,
    ROUND(AVG(AVG(e.grade)) OVER (PARTITION BY g.name), 1) AS group_avg_grade
FROM student s
JOIN student_group g USING(group_id)
JOIN enrolment e USING(student_id)
WHERE e.grade IS NOT NULL 
GROUP BY s.student_id, s.name,s.surname, g.name
ORDER BY g.name ASC;
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали

SELECT
	c.student_year, 
	COUNT(DISTINCT(c.course_id)) as course_count, 
	COUNT( e.student_id) as enrolment_count, 
	COUNT(DISTINCT student_id) FILTER(WHERE e.grade IS NOT NULL) AS number_of_students_with_grades
FROM course c
INNER JOIN enrolment e USING(course_id)
GROUP BY c.student_year;
