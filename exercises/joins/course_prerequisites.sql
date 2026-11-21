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
    c.course_name AS course_name,
    pc.course_name AS prerequisite_name
FROM course AS c
LEFT JOIN course_prerequisite AS cp
    ON cp.course_id = c.course_id
LEFT JOIN course AS pc
    ON pc.course_id = cp.prerequisite_course_id
ORDER BY
    c.course_name ASC,
    pc.course_name ASC;
