-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT
    CONCAT(p.first_name, ' ', p.last_name) as professor_name,
    pr1.job FROM person p 
JOIN professor pr1 ON p.person_id = pr1.person_id
WHERE pr1.professor_id NOT IN (
        SELECT pr2.professor_id FROM professor pr2
        JOIN student_group sg ON pr2.professor_id = sg.curator_id
    )
    AND pr1.status = 'викладає'
ORDER BY professor_name
