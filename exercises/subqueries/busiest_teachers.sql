-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
SELECT c.name as course_name,  p.first_name || ' ' || p.last_name as teacher_name,  ct.professor_role as role 
    FROM course as c
 JOIN course_teacher ct ON ct.course_id = c.course_id
 JOIN professor pr ON ct.professor_id = pr.professor_id 
 JOIN person p ON  pr.person_id = p.person_id 
WHERE c.status = 'активний'
  
ORDER BY course_name, role;
