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
select c.course_name, p.first_name || ' ' || p.last_name as professor_name, ct.professor_role as role from course c
left join course_teacher ct using (course_id)
left join professor using (professor_id)
left join person p using (person_id)
where course_status='active'
order by c.course_name, ct.professor_role