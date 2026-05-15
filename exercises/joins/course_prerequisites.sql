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
    pre.name AS prerequisite_name
FROM courses c
JOIN course_prerequisites cp ON c.id = cp.course_id
JOIN courses pre ON cp.prerequisite_id = pre.id
ORDER BY course_name;
