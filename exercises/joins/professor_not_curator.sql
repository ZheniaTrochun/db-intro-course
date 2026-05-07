-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT p.first_name || ' ' || p.last_name AS professor_name, pr.job
FROM student_group g
	right join professor pr ON curator_id = professor_id
	join person p USING(person_id)
WHERE curator_id IS NULL AND pr.status = 'викладає'
ORDER BY professor_name;