-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT prsn.first_name || ' ' || prsn.last_name AS professor_name, prof.job_title AS job_title
FROM professor prof
LEFT JOIN student_group s ON prof.professor_id = s.curator_id
LEFT JOIN person prsn ON prof.person_id = prsn.person_id
WHERE prof.professor_status = 'active'
AND s.curator_id IS NULL
ORDER BY professor_name