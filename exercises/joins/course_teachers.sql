-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'active'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Рішення:
select c.course_name, p.first_name || ' ' || p.last_name AS professor_name, ct.professor_role AS role
from course c
left join course_teacher ct ON c.course_id = ct.course_id
left join professor pr ON ct.professor_id = pr.professor_id
left join person p ON pr.person_id = p.person_id
where c.course_status = 'active'
order by c.course_name, role;