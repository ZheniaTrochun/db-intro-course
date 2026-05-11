-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
SELECT p.first_name || ' ' || p.last_name as professor_name, pr.job as job
  FROM professor as pr 
 JOIN person p ON pr.person_id = p.person_id
 LEFT JOIN student_group sg ON pr.professor_id = sg.curator_id
WHERE pr.status = 'викладає' AND sg.curator_id IS NULL

ORDER BY professor_name;
