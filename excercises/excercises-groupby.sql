-- порахувати успішність студентів залежно від року навчання
SELECT student_year, round(avg(grade), 1) as avg_year_grade
FROM course c
INNER JOIN enrolment e
USING (course_id)
GROUP BY student_year
HAVING avg(grade) IS NOT NULL
ORDER BY student_year;
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
SELECT DISTINCT
    student_id,
    s.name || ' ' || surname AS full_name,
    round(avg(grade) OVER (PARTITION BY student_id), 1) AS avg_student_grade,
    sg.name,
    round(avg(grade) OVER (PARTITION BY group_id), 1) AS avg_student_grade
FROM enrolment e
    INNER JOIN student s USING (student_id)
    INNER JOIN student_group sg USING (group_id)
WHERE grade IS NOT NULL
ORDER BY student_id;
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
SELECT
    student_year,
    count(DISTINCT course_id) AS number_of_courses,
    count(*) AS number_of_enrolments,
    count(student_id) FILTER ( WHERE grade IS NOT NULL) AS number_of_students_with_grade
FROM enrolment e
    INNER JOIN course c USING (course_id)
GROUP BY student_year

