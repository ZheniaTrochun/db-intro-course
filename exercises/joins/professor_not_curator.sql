-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT
    CONCAT(pr.first_name, ' ', pr.last_name) AS professor_name,
    p.job
FROM professor p
JOIN person pr ON p.person_id = pr.person_id
LEFT JOIN student_group sg ON p.professor_id = sg.curator_id
WHERE p.status = 'викладає' AND sg.group_id IS NULL
ORDER BY professor_name;