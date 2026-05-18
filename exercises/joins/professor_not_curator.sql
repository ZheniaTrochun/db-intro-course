-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
select p.first_name || ' ' || p.last_name as "professor_name",
  pr1.job from person p 
join professor pr1 on p.person_id = pr1.person_id
where pr1.professor_id not in (
  select pr2.professor_id from professor pr2
  join student_group sg on pr2.professor_id = sg.curator_id
)
and pr1.status = 'викладає'
order by professor_name
