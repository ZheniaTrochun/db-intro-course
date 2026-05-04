-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
select 
    p_pro.first_name ||' '|| p_pro.last_name as professor_name,
    pro.job as job
from professor pro
inner join person p_pro on p_pro.person_id = pro.person_id
left join student_group sg on sg.curator_id = pro.professor_id
where pro.status = u&'\0432\0438\043a\043b\0430\0434\0430\0454'
    and sg.curator_id is null
order by professor_name, job;