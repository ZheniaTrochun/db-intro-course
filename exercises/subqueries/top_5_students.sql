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

WITH ranked_students AS (
	SELECT
	    c.course_name,
	    e.student_id,
	    p.first_name || ' ' || p.last_name AS student_full_name,
	    e.grade,
		ROW_NUMBER() OVER (
		    PARTITION BY c.course_id
		    ORDER BY e.grade DESC,
		             p.first_name || ' ' || p.last_name,
		             e.student_id
		) AS rank
	FROM enrolment e
	INNER JOIN course c ON c.course_id = e.course_id
	INNER JOIN student s ON e.student_id = s.student_id
	INNER JOIN person p ON s.person_id = p.person_id
	WHERE e.grade IS NOT NULL
	)
SELECT *
FROM ranked_students rs
WHERE rs.rank <= 5
ORDER BY rs.course_name, rs.rank, rs.student_full_name, rs.student_id;