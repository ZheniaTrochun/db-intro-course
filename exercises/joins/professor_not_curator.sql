-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT p.first_name || ' ' || p.last_name AS professor_name, pf.job AS job
FROM professor pf
LEFT JOIN person p ON pf.person_id = p.person_id
LEFT JOIN student_group sg ON sg.curator_id = pf.professor_id
WHERE pf.status = 'викладає' AND sg.curator_id IS NULL
ORDER BY professor_name;