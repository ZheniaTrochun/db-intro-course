-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента, потім за ідентифікатор студента

-- Рішення:


WITH count_values AS(
	SELECT
		s.student_id,
		concat_ws(' ', p.first_name, p.last_name) AS full_name,
		COUNT(e.course_id) AS course_number
	FROM student s
	INNER JOIN person p USING(person_id)
	INNER JOIN enrolment e USING(student_id)
	INNER JOIN course c USING(course_id)
	GROUP BY s.student_id, p.first_name, p.last_name
), 
count_avarage AS (
	SELECT
		c.student_id,
		c.full_name,
		c.course_number,
		ROUND(AVG(c.course_number) OVER(), 2) AS avg_number
	FROM count_values c
)

SELECT 
	student_id,
	full_name,
	course_number,
	avg_number
FROM count_avarage
WHERE course_number > avg_number
ORDER BY course_number DESC, full_name, student_id;