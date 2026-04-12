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
    pr.job
FROM professor pr
JOIN person p ON pr.person_id = p.id
LEFT JOIN student_group sg ON pr.id = sg.curator_id
WHERE pr.status = 'викладає' 
  AND sg.id IS NULL
ORDER BY professor_name;
