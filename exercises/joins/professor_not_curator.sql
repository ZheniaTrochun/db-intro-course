-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT 
    p.first_name || ' ' || p.last_name AS professor_name,
    prof.job
FROM professor prof
JOIN person p ON prof.person_id = p.person_id
LEFT JOIN student_group sg ON prof.professor_id = sg.curator_id
WHERE 
    prof.status = 'викладає' 
    AND sg.curator_id IS NULL
ORDER BY 
    professor_name ASC;