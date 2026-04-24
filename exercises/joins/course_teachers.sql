-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'активний'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Рішення:
select 
    c.name as course_name,
    p_pro.first_name || ' ' || p_pro.last_name as teacher_name,
    ct.professor_role as role
from course c
inner join course_teacher ct on c.course_id = ct.course_id
inner join professor pro on pro.professor_id = ct.professor_id
inner join person p_pro on p_pro.person_id = pro.person_id
where c.status = u&'\0430\043a\0442\0438\0432\043d\0438\0439'
order by course_name, role, teacher_name;