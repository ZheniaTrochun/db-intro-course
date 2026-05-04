-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT DISTINCT
  p.first_name || ' ' || p.last_name AS professor_name,
  pr.job
FROM professor pr
JOIN person p ON pr.person_id = p.person_id
WHERE pr.status::text = 'викладає'
  AND pr.professor_id NOT IN (SELECT curator_id FROM student_group WHERE curator_id IS NOT NULL)
ORDER BY professor_name;
