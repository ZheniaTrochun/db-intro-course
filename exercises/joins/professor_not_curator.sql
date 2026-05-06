-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT pe.first_name || ' ' || pe.last_name AS professor_name,
	   pr.job
FROM professor pr JOIN person pe USING(person_id)
LEFT JOIN student_group sg ON sg.curator_id = pr.professor_id
WHERE pr.status = 'викладає' AND sg.curator_id is NULL
ORDER BY professor_name;