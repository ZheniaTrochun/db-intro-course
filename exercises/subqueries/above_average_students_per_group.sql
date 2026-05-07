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
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:

WITH avg_student_grade AS (
    SELECT student_id, AVG(grade) as avg_student_grade
    FROM enrolment e
		join student s using(student_id)
        join person p using(person_id)
	WHERE grade IS NOT NULL
    GROUP BY student_id, first_name, last_name
),
avg_group_grade AS (
    SELECT AVG(grade) as avg_group_grade, name
    FROM student_group sg
		inner join student s using(group_id)
        inner join enrolment e using(student_id)
    GROUP BY name
)
SELECT student_id, first_name || ' ' || last_name AS full_name, sg.name AS group_name,
	ROUND(avg_student_grade, 2) AS avg_student_grade, ROUND(avg_group_grade, 2) AS avg_group_grade
FROM student s
	join person p using(person_id)
	join student_group sg using(group_id)
	join avg_student_grade using(student_id)
	JOIN avg_group_grade USING (name)
WHERE avg_student_grade > avg_group_grade
ORDER BY group_name, avg_student_grade DESC, full_name;