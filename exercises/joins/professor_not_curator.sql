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
JOIN person p USING (person_id)
WHERE prof.status = 'викладає'
AND NOT EXISTS (
SELECT 1
FROM student_group sg
WHERE sg.curator_id = prof.professor_id
)
ORDER BY professor_name ASC;