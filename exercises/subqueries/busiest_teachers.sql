-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:

WITH professor_credits AS (
   SELECT *
     FROM professor pr
     LEFT JOIN course_teacher ct USING(professor_id)
     INNER JOIN course c USING(course_id)
     LEFT JOIN person p USING(person_id) 
),
avg_total_credits AS (
   SELECT AVG(prof_sum.total_credits) AS avg_total_credits
   FROM (
       SELECT SUM(credits) AS total_credits
       FROM professor_credits
       GROUP BY professor_id
   ) prof_sum
)

SELECT 
      pc.first_name || ' ' || pc.last_name AS full_name,
      SUM(credits) AS total_credits,
      ROUND((SELECT avg_total_credits FROM avg_total_credits), 2)::DOUBLE PRECISION AS avg_total_credits
FROM professor_credits pc
GROUP BY pc.professor_id, pc.first_name, pc.last_name
ORDER BY total_credits DESC, full_name ASC
LIMIT 100;