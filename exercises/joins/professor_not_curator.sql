-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT p.first_name || ' ' || p.last_name AS professor_name, prof.job AS job
FROM professor prof
LEFT JOIN person p ON p.person_id = prof.person_id
LEFT JOIN student_group sg ON sg.curator_id = prof.professor_id
WHERE prof.status = 'викладає' and sg.curator_id IS NULL
ORDER BY professor_name;