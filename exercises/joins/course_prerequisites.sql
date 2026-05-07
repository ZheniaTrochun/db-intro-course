-- Завдання:
--      Сформувати список усіх курсів разом з їхніми пре-реквізитами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - назва пре-реквізиту (prerequisite_name)
--      Включити усі курси, навіть ті, що не мають пре-реквізитів
--      Результат відсортувати за:
--          - назвою курсу, потім за назвою пре-реквізиту

-- Рішення:
SELECT c.name AS course_name, c2.name AS prerequisite_name
FROM course c
	left join course_prerequisite p USING(course_id)
	left join course c2 ON p.prerequisite_course_id = c2.course_id
ORDER BY course_name, prerequisite_name;