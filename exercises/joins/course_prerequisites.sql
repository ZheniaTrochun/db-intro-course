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
    crs.name AS course_name,
    prereq.name AS prerequisite_name
FROM course crs
LEFT JOIN course_prerequisite c_p ON crs.course_id = c_p.course_id
LEFT JOIN course prereq ON c_p.prerequisite_course_id = prereq.course_id
ORDER BY crs.name, prereq.name;
