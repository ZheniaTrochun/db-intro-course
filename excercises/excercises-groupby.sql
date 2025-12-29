-- порахувати успішність студентів залежно від року навчання

SELECT
    c.student_year,
    ROUND(AVG(e.grade),2) AS avg_grade
FROM enrolment e
         JOIN course c ON e.course_id = c.course_id
GROUP BY c.student_year
ORDER BY c.student_year;


-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі

SELECT
    student_id,
    name,
    surname,
    student_avg,
    ROUND(AVG(student_avg) OVER (PARTITION BY group_id), 2) AS group_avg
FROM (
         SELECT
             s.student_id,
             s.name,
             s.surname,
             s.group_id,
             ROUND(AVG(e.grade), 2) AS student_avg
         FROM student s
                  JOIN enrolment e ON s.student_id = e.student_id
         WHERE e.grade IS NOT NULL
         GROUP BY s.student_id, s.name, s.surname, s.group_id
     );


-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали

SELECT
    c.student_year,
    COUNT(DISTINCT c.course_id) AS courses_count,
    COUNT(e.student_id) AS enrolments_count,
    COUNT(e.grade) AS graded_students
FROM course c
         LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year
ORDER BY c.student_year;
