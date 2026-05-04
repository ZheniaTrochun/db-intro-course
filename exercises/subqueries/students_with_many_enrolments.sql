-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента

-- Рішення:
WITH count_stud_enrolments as(
	SELECT  s.student_id,
		CONCAT(p.first_name, ' ', p.last_name) AS full_name,
		COUNT (e.course_id) as total_courses
FROM person p
	inner join student s USING(person_id)
	inner join enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, p.person_id, p.first_name, p.last_name),
avg_stud_enrolments AS (
    SELECT AVG(total_courses) AS avg_total_courses
    FROM count_stud_enrolments)
SELECT
	cse.student_id,
    cse.full_name,
    ROUND(cse.total_courses, 2) as course_number,
    ROUND(ase.avg_total_courses, 2) as avg_number
FROM count_stud_enrolments cse
    CROSS JOIN avg_stud_enrolments ase
WHERE cse.total_courses > ase.avg_total_courses
ORDER BY 
    cse.total_courses DESC, 
    cse.full_name ASC
