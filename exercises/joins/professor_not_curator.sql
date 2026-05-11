-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT DISTINCT(dnp.first_name || ' ' || dnp.last_name) as professor_name, p.job
FROM professor p
LEFT JOIN person dnp on p.person_id = dnp.person_id
LEFT JOIN student_group sg on p.professor_id = sg.curator_id
WHERE p.status = 'викладає' AND sg.group_id is NULL
ORDER BY professor_name;