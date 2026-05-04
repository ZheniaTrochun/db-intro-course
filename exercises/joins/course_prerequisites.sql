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
 c.name as course_name,
 p.name as prerequisite_name
FROM course c
LEFT JOIN course_prerequisite cp on c.course_id = cp.course_id
LEFT JOIN course p on cp.prerequisite_course_id = p.course_id
ORDER by course_name ASC, prerequisite_name ASC;