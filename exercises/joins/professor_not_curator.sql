-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT p.first_name || ' ' || p.last_name as "professor_name", pr.job as "job"
FROM professor pr 
	JOIN person p
		on pr.person_id = p.person_id
	LEFT JOIN student_group sg 
		on sg.curator_id = pr.professor_id
WHERE pr.status = 'викладає' and sg.curator_id is NULL
ORDER BY p.first_name || ' ' || p.last_name;