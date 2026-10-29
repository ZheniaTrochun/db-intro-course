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
    c.course_name,
    per.first_name || ' ' || per.last_name as professor_name,
    ct.professor_role as role
from course c
join course_teacher ct using (course_id)
join professor pr using (professor_id)
join person per using (person_id)
where c.course_status = 'active'
order by course_name, role
