-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:
SELECT DISTINCT(s.student_id) AS student_id,
	p.first_name || ' ' || p.last_name AS full_name, 
	ROUND(AVG(e.grade), 2) AS avg_student_grade, 
	g.name AS group_name,
	ROUND(AVG(e2.avg_grade), 2) AS avg_group_grade
from student s
	join person p USING(person_id)
	join student_group g USING(group_id)
	join enrolment e USING(student_id)

	join student s2 USING(group_id)
	join (
    SELECT student_id, AVG(grade) AS avg_grade
    from enrolment
    GROUP BY student_id
    ) e2 ON e2.student_id = s2.student_id
GROUP BY s.student_id, full_name, g.name
ORDER BY g.name, full_name;
