-- Завдання:
--      Сформувати список усіх курсів разом з їхніми пре-реквізитами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - назва пре-реквізиту (prerequisite_name)
--      Включити усі курси, навіть ті, що не мають пре-реквізитів
--      Результат відсортувати за:
--          - назвою курсу, потім за назвою пре-реквізиту

-- Рішення:
SELECT c.name AS course_name,
	   cp_c.name AS prerequisite_name
FROM course c LEFT JOIN course_prerequisite cp USING(course_id)
LEFT JOIN course cp_c ON cp.prerequisite_course_id = cp_c.course_id
ORDER BY c.name, cp_c.name