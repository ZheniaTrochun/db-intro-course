-- Завдання:
--      Сформувати список усіх курсів разом з їхніми пре-реквізитами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - назва пре-реквізиту (prerequisite_name)
--      Включити усі курси, навіть ті, що не мають пре-реквізитів
--      Результат відсортувати за:
--          - назвою курсу, потім за назвою пре-реквізиту

-- Рішення:

SELECT
	c.course_name,
	prerequisite.course_name AS prerequisite_name
FROM course c
LEFT JOIN course_prerequisite p 
	USING(course_id)
LEFT JOIN course prerequisite 
	ON prerequisite.course_id = p.prerequisite_course_id
ORDER BY c.course_name, prerequisite_name;
