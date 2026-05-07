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
SELECT student_id, full_name, course_number, avg_number
FROM
(
SELECT student_id, first_name || ' ' || last_name AS full_name, COUNT (course_id) AS course_number, 
	(
	SELECT ROUND(AVG(N), 2) as avg_n
	FROM (
	SELECT COUNT(course_id) AS N
	FROM student s
	join person p using(person_id)
	join enrolment e using(student_id)
	GROUP BY student_id
	)) AS avg_number
FROM student s
	join person p using(person_id)
	join enrolment e using(student_id)
GROUP BY student_id, full_name
)
WHERE course_number > avg_number
ORDER BY course_number DESC, full_name;
