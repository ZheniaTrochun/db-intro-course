-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
select p.first_name || ' ' || p.last_name AS professor_name, job_title
from professor pr
left join person p on pr.person_id = p.person_id
left join student_group sg on pr.professor_id = sg.curator_id
where pr.professor_status = 'active' and sg.curator_id isnull
order by professor_name;