-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT p.first_name || ' ' || p.last_name as professor_name, pf.job
FROM professor pf
	left join person p USING(person_id)
	left join student_group sg ON pf.professor_id=sg.curator_id
WHERE pf.status = 'викладає' AND sg.group_id is null
ORDER BY professor_name;
