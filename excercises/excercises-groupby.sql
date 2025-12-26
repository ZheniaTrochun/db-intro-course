-- порахувати успішність студентів залежно від року навчання
SELECT c.student_year, ROUND(AVG(e.grade),1) as "Середня оцінка" 
FROM course c
JOIN enrolment e USING(course_id)
GROUP BY c.student_year
ORDER BY c.student_year
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
SELECT
DISTINCT s.student_id,
s.surname || ' ' || s.name AS "Студент",
g.name AS "Група",
ROUND(AVG(e.grade) OVER (PARTITION BY s.student_id), 1) AS "Середній бал студента",
ROUND(AVG(e.grade) OVER (PARTITION BY s.group_id), 1) AS "Середній бал по групі"
FROM student s
JOIN student_group g USING (group_id)
JOIN enrolment e USING (student_id)
WHERE e.grade IS NOT NULL
ORDER BY s.student_id
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
SELECT
c.student_year AS "Рік навчання",
COUNT(DISTINCT c.course_id) AS "Кількість курсів",
COUNT(e.student_id) AS "Кількість записів",
COUNT(DISTINCT e.student_id) FILTER (WHERE e.grade IS NOT NULL) AS "Студентів з оцінками"
FROM course c
LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year;
