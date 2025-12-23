--Всі запити та дані використані з файлів aggregations.sql, create-campus-tables.sql, insert-data.sql
-- порахувати успішність студентів залежно від року навчання
SELECT start_year, ROUND(AVG(grade), 1) AS avg_grade
FROM student
  JOIN enrolment USING (student_id)
  JOIN student_group USING (group_id)
WHERE grade IS NOT NULL
GROUP BY start_year
ORDER BY start_year;
--
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
--
SELECT DISTINCT
    s.name || ' ' || s.surname AS full_name,
    ROUND(AVG(grade) OVER (PARTITION BY s.student_id), 1) AS my_avg,
    --в рядку 16 додав round,щоб менше знаків після коми було(неуважно зробив в минулий раз) 
    ROUND(AVG(grade) OVER (PARTITION BY s.group_id), 1) AS group_avg
FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    JOIN student_group g ON s.group_id = g.group_id
WHERE grade IS NOT NULL
ORDER BY full_name;
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали
SELECT start_year,
  COUNT(DISTINCT course_id) AS courses,
  COUNT(*) AS total_recs,
  COUNT(grade) AS passed
FROM student_group 
  INNER JOIN student USING (group_id)
  INNER JOIN enrolment USING (student_id)
GROUP BY start_year
ORDER BY start_year;

