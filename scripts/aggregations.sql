-- порахувати розміри груп
SELECT group_id, g.name, count(student_id) as group_size
FROM student_group g LEFT JOIN student s USING (group_id)
GROUP BY group_id, g.name
ORDER BY g.name;

-- порахувати навантаження викладачів - скільки активних курсів та кредитів викладає кожен з викладачів
SELECT
	t.name || ' ' || t.surname as full_name,
	count(course_id) as number_of_courses,
	sum(credits) as sum_of_credits
FROM teacher t LEFT JOIN course c USING(teacher_id)
WHERE is_active
GROUP BY t.teacher_id, t.name, t.surname
ORDER BY sum_of_credits DESC, full_name ASC;

-- знайти усіх студентів, середній бал яких більше 90
SELECT
	s.name || ' ' || s.surname as full_name,
	ROUND(AVG(grade), 1) as avg_grade
FROM student s INNER JOIN enrolment e USING (student_id)
WHERE grade is not null
GROUP BY s.name, s.surname
HAVING AVG(grade) > 90
ORDER BY avg_grade DESC;

-- отримати оцінки студентів у порівнянні з середнім балом по предмету
-- додати середній бал студента
SELECT
	s.name || ' ' || s.surname as full_name,
	c.name as course_name,
	grade,
	ROUND(AVG(grade) OVER (PARTITION BY course_id), 1) as avg_course_grade,
	ROUND(AVG(grade) OVER (PARTITION BY student_id), 1) as avg_student_grade
FROM student s INNER JOIN enrolment e USING (student_id) INNER JOIN course c USING (course_id)
WHERE grade is not null
ORDER BY full_name ASC;


-- побудувати список за успішністю по групам
SELECT
    s.name || ' ' || s.surname as full_name,
    g.name as group_name,
    ROUND(COALESCE(AVG(grade), 0), 1) as avg_student_grade,
    row_number() over (PARTITION BY g.name ORDER BY COALESCE(AVG(grade), 0) DESC) as student_rank
FROM student s
         INNER JOIN enrolment e USING (student_id)
         INNER JOIN student_group g USING (group_id)
GROUP BY s.name, s.surname, g.name
ORDER BY group_name ASC, student_rank ASC;

-- порахувати успішність студентів залежно від року навчання
--
-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі
--
-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали


