-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:

SELECT 
   p.first_name || ' ' || p.last_name AS professor_name,
   pr.job_title
FROM professor pr
LEFT JOIN person p USING (person_id)
LEFT JOIN student_group sg ON pr.professor_id = sg.curator_id
WHERE professor_status = 'active' AND sg.curator_id IS NULL
ORDER BY professor_name