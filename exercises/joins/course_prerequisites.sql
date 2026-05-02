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
    c.name AS course_name,
    pr.name AS prerequisite_name
FROM course c
JOIN course_prerequisite cp ON c.course_id = cp.course_id
JOIN course pr ON cp.prerequisite_course_id = pr.course_id
ORDER BY course_name ASC, prerequisite_name ASC;