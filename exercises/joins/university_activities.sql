-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'активний')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:
select
    p.first_name || ' ' || p.last_name as full_name,
    c.name as course_name,
    u&'\0437\0430\043f\0438\0441 \043d\0430 \043a\0443\0440\0441' as activity_type
from enrolment e
join student s on s.student_id = e.student_id
join person p on p.person_id = s.person_id
join course c on c.course_id = e.course_id
where c.status = u&'\0430\043a\0442\0438\0432\043d\0438\0439'

union all

select
    p.first_name || ' ' || p.last_name as full_name,
    c.name as course_name,
    u&'\0432\0438\043a\043b\0430\0434\0430\043d\043d\044f \043a\0443\0440\0441\0443' as activity_type
from course_teacher ct
join professor pro on pro.professor_id = ct.professor_id
join person p on p.person_id = pro.person_id
join course c on c.course_id = ct.course_id
where c.status = u&'\0430\043a\0442\0438\0432\043d\0438\0439'
order by course_name, activity_type, full_name;