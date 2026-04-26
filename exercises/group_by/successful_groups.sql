-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:
SELECT
    group_name,
    count(student_id) AS student_count,
    round(avg(grade),2) AS avg_grade
FROM groups
JOIN students ON students.group_id=groups.group_id
GROUP BY group_name
HAVING avg(grade) >75 --щоб побачити всі колонки без обмеження "більше за 75", треба прибрати цю строчку
ORDER BY avg_grade DESC, group_name;
