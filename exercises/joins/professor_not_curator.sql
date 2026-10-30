-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT person.first_name || ' ' || person.last_name AS professor_name, professor.job_title
FROM professor
INNER JOIN person ON person.person_id = professor.person_id
WHERE professor.professor_status = 'active'
AND NOT EXISTS (SELECT 1 FROM student_group WHERE student_group.curator_id = professor.professor_id)
ORDER BY professor_name;
