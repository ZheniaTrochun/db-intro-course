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
    c1.name AS course_name,
    c2.name AS prerequisite_name
FROM course c1
LEFT JOIN course_prerequisite cp ON c1.course_id = cp.course_id
LEFT JOIN course c2 ON cp.prerequisite_course_id = c2.course_id
ORDER BY 
    course_name ASC, 
    prerequisite_name ASC;