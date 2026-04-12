-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:

WITH student_performance AS (
    -- Крок 1: Рахуємо середній бал для кожного з 1000 студентів
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        sg.name AS group_name,
        s.group_id,
        AVG(e.grade) AS student_avg
    FROM
        student s
    JOIN
        person p ON s.person_id = p.person_id
    JOIN
        student_group sg ON s.group_id = sg.group_id
    LEFT JOIN
        enrolment e ON s.student_id = e.student_id
    GROUP BY
        s.student_id, p.first_name, p.last_name, sg.name, s.group_id
)
SELECT
    student_id,
    full_name,
    -- Крок 2: Округляємо та приводимо до потрібного типу
    ROUND(student_avg::numeric, 2)::numeric(38,2) AS avg_student_grade,
    group_name,
    -- Крок 3: Рахуємо середнє по групі на основі середніх балів студентів
    ROUND(AVG(student_avg) OVER (PARTITION BY group_id)::numeric, 2)::numeric(38,2) AS avg_group_grade
FROM
    student_performance
ORDER BY
    group_name ASC,
    full_name ASC;