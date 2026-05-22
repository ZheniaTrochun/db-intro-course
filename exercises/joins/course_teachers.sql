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
    concat(p.first_name, ' ', p.last_name) as teacher_name,
    ct.professor_role as role
from course c
join course_teacher ct on c.course_id = ct.course_id
join professor pr on ct.professor_id = pr.professor_id
join person p on pr.person_id = p.person_id
where c.status = (enum_range(null::course_status))[1]
order by c.name, ct.professor_role;
