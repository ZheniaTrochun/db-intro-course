-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
select p.first_name || ' ' || p.last_name as professor_name,
pr.job_title as job_title
from professor pr 
left join student_group sg
on pr.professor_id = sg.curator_id
inner join person p
on pr.person_id = p.person_id
where sg.curator_id is null and pr.professor_status = 'active'
order by professor_name;