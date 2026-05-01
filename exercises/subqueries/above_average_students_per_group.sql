-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:
WITH avg_scores AS (
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        AVG(e.grade)::numeric AS avg_val
    FROM student s
    JOIN person p USING(person_id)
    JOIN enrolment e USING(student_id)
    WHERE e.grade IS NOT NULL
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
group_avg AS (
    SELECT
        s.group_id,
        AVG(e.grade)::numeric AS group_avg
    FROM student s
    JOIN enrolment e USING(student_id)
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
),
filtered AS (
    SELECT
        avg_sc.student_id,
        avg_sc.full_name,
        sg.name AS group_name,
        avg_sc.avg_val,
        gp.group_avg
    FROM avg_scores avg_sc
    JOIN group_avg gp USING(group_id)
    JOIN student_group sg USING(group_id)
    WHERE avg_sc.avg_val > gp.group_avg
)
SELECT
    (ROW_NUMBER() OVER (ORDER BY group_name ASC, avg_val DESC, full_name ASC, student_id ASC) - 1)::int AS row_number,
    student_id,
    full_name,
    group_name,
    ROUND(avg_val, 2)::float8 AS avg_student_grade,
    ROUND(group_avg, 2)::float8 AS avg_group_grade
FROM filtered
ORDER BY
    group_name ASC, avg_val DESC, full_name ASC;