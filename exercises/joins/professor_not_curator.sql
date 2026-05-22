-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:

select
    concat(p.first_name, ' ', p.last_name) as professor_name,
    pr.job as job
from professor pr
join person p on pr.person_id = p.person_id
left join student_group sg on pr.professor_id = sg.curator_id
where pr.status = (enum_range(null::professor_status))[1]
  and sg.group_id is null
order by professor_name;
