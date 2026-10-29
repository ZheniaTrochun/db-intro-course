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
	  c.course_name as course_name,
	  pc.course_name as prerequisite_name
from course c
left join course_prerequisite cp using (course_id)
left join course pc on (cp.prerequisite_course_id = pc.course_id)
order by course_name, prerequisite_name
