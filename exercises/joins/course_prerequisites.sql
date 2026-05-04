-- Завдання:
--      Сформувати список усіх курсів разом з їхніми пре-реквізитами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - назва пре-реквізиту (prerequisite_name)
--      Включити усі курси, навіть ті, що не мають пре-реквізитів
--      Результат відсортувати за:
--          - назвою курсу, потім за назвою пре-реквізиту

-- Рішення:
SELECT c1.name as course_name, c2.name as prerequisite_name
FROM course_prerequisite cp
	right join course c1 USING(course_id)
	left join course c2 ON c2.course_id=cp.prerequisite_course_id
ORDER BY course_name, prerequisite_name;
