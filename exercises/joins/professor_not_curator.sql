-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT 
    p_person.first_name || ' ' || p_person.last_name AS professor_name,
    p.job
FROM professor p
JOIN person p_person 
    ON p_person.person_id = p.person_id
LEFT JOIN student_group sg 
    ON sg.curator_id = p.professor_id
WHERE 
    p.status = 'викладає'
    AND sg.curator_id IS NULL
ORDER BY 
    professor_name ASC;