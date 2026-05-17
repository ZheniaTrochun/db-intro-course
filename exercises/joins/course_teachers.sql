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
select c.name as course_name, ppr.first_name || ' ' || ppr.last_name as teacher_name,
ct.professor_role as role
from course c
join course_teacher ct on c.course_id = ct.course_id
join professor pr on ct.professor_id = pr.professor_id
join person ppr on pr.person_id = ppr.person_id
where c.status = 'активний'
order by course_name, role;