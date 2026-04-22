-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:

SELECT per.first_name || ' ' || per.last_name AS professor_name, pr.job AS job 
FROM professor pr
INNER JOIN person per ON pr.person_id = per.person_id
LEFT JOIN student_group g ON pr.person_id = g.curator_id

WHERE pr.status = 'викладає' AND g.curator_id IS NULL
ORDER BY professor_name;