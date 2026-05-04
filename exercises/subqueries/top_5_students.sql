-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank)
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента

-- Рішення:
WITH RankList AS (
	SELECT c.name AS course_name, e.student_id, p.first_name || ' ' || p.last_name AS full_name,
    e.grade, ROW_NUMBER() OVER (PARTITION BY c.course_id
    ORDER BY e.grade DESC NULLS LAST, (p.first_name || ' ' || p.last_name)) AS student_rank
	FROM enrolment e
	JOIN course c ON e.course_id = c.course_id
	JOIN student s ON e.student_id = s.student_id
	JOIN person p ON s.person_id = p.person_id)

SELECT rl.course_name, rl.student_id, rl.full_name as student_full_name, rl.grade as grade, 
rl.student_rank as rank
FROM RankList rl
WHERE rl.student_rank < 6
ORDER BY course_name, student_rank, student_full_name