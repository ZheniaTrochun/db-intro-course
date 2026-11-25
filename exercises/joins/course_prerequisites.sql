-- Завдання:
--      Сформувати список усіх курсів разом з їхніми пре-реквізитами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - назва пре-реквізиту (prerequisite_name)
--      Включити усі курси, навіть ті, що не мають пре-реквізитів
--      Результат відсортувати за:
--          - назвою курсу, потім за назвою пре-реквізиту

-- Рішення:
select 
    c1.course_name as course_name, 
    c2.course_name as prerequisite_name
from course c1
left join course_prerequisite cp on c1.course_id = cp.course_id
left join course c2 on cp.prerequisite_course_id = c2.course_id
order by c1.course_name, c2.course_name;
