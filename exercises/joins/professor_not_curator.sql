-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
-- Querie where job is null
SELECT 
      p.first_name || ' ' || p.last_name AS professor_name,
      pr.job_title AS job_title
FROM professor pr
INNER JOIN person p ON p.person_id = pr.person_id
LEFT JOIN student_group sg ON sg.curator_id = pr.professor_id
WHERE pr.professor_status = 'active'
      AND sg.curator_id IS NULL
ORDER BY professor_name;