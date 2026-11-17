-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:

WITH avg_student_grade AS (
	SELECT 
		s.student_id, 
		concat_ws(' ', p.first_name, p.last_name) AS full_name,
		-- ROUND(AVG(COALESCE(e.grade, 0)), 2)::float8 AS avg_student_grade,
        ROUND(AVG(e.grade), 2)::float8 AS avg_student_grade,
		sga.group_id
	FROM student s
	INNER JOIN person p USING(person_id)
	INNER JOIN enrolment e USING(student_id)
	INNER JOIN student_group_assignment sga USING(student_id)
	GROUP BY s.student_id, sga.group_id, p.first_name, p.last_name
),
avg_group_grade AS (
	SELECT 
		sg.group_name,
		sg.group_id,
        -- ROUND(AVG(COALESCE(e.grade, 0)), 2)::float8 AS avg_group_grade
		ROUND(AVG(e.grade), 2)::float8 AS avg_group_grade
		
	FROM student_group sg
	INNER JOIN student_group_assignment sga USING(group_id)
	INNER JOIN enrolment e USING(student_id)
	GROUP BY sg.group_id, sg.group_name
)

SELECT 
	a.student_id,
    a.full_name,
    g.group_name,
    a.avg_student_grade,
    g.avg_group_grade	
FROM avg_student_grade a
INNER JOIN avg_group_grade g USING(group_id)
	WHERE a.avg_student_grade > g.avg_group_grade
ORDER BY g.group_name, a.avg_student_grade DESC, a.full_name, a.student_id