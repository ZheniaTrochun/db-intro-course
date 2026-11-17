-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank) - за балом, іменем студента та ідентифікатором студента
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:

WITH cte AS(
	SELECT
		c.course_name,
		s.student_id,
		concat_ws(' ', p.first_name, p.last_name) AS student_full_name,
		COALESCE(e.grade, 0) AS grade,
		DENSE_RANK() OVER (PARTITION BY c.course_id
			ORDER BY e.grade DESC NULLS LAST, concat_ws(' ', p.first_name, p.last_name), s.student_id) AS rank
	FROM student s
	INNER JOIN person p USING(person_id)
	INNER JOIN enrolment e USING(student_id)
	INNER JOIN course c USING(course_id)
)

SELECT 
	course_name,
	student_id,
	student_full_name,
	grade,
	rank
FROM cte
WHERE rank <= 5
ORDER BY course_name, rank ASC, student_full_name, student_id ASC;