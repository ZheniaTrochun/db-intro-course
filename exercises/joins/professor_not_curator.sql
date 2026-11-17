-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:

SELECT 
	concat_ws(' ', p.first_name, p.last_name) AS professor_name,
	prof.job_title
	FROM professor prof
INNER JOIN person p USING(person_id)
LEFT JOIN student_group g
	ON g.curator_id = prof.professor_id
WHERE g.curator_id IS NULL 
	AND prof.professor_status = 'active'
ORDER BY professor_name ASC;