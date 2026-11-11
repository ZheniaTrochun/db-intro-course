-- =========================
-- COUNT, AVG, SUM, MIN, MAX
-- =========================

-- Загальна кількість зареєстрованих студентів та діапазон років вступу
SELECT 
    COUNT(*) AS total_students,
    MIN(admission_year) AS earliest_admission,
    MAX(admission_year) AS latest_admission
FROM academic_groups g
JOIN students s ON g.group_id = s.group_id

-- Середній підсумковий бал студентів за кожен семестр
SELECT 
    semester,
    COUNT(enrollment_id) AS completed_courses_count,
    ROUND(AVG(final_grade), 2) AS avg_final_grade
FROM enrollments
WHERE status = 'Completed'
GROUP BY semester

-- Загальний обсяг ECTS-кредитів дисциплін за кожною кафедрою
SELECT 
    department_id,
    COUNT(course_id) AS total_courses,
    SUM(ects_credits) AS total_ects_credits
FROM courses
GROUP BY department_id

-- Кількість поточних оцінок та середній бал за кожним типом навчальної роботи
SELECT 
    work_type,
    COUNT(grade_id) AS grades_count,
    ROUND(AVG(score), 2) AS avg_score,
    MIN(score) AS min_score,
    MAX(score) AS max_score
FROM grade_records
GROUP BY work_type


-- ======
-- HAVING
-- ======

-- Курси, на яких навчається більше 1 студента зі статусом 'Completed' або 'Active'
SELECT 
    course_id,
    COUNT(student_id) AS active_enrolled_students
FROM enrollments
WHERE status IN ('Active', 'Completed')
GROUP BY course_id
HAVING COUNT(student_id) > 1

-- =======================
-- INNER, LEFT, RIGHT JOIN
-- =======================

-- INNER JOIN: Студенти та назви їхніх навчальних груп
SELECT 
    s.full_name AS student_name,
    g.group_name
FROM students s
JOIN academic_groups g ON s.group_id = g.group_id

-- INNER JOIN: Викладачі та їхні кафедри
SELECT 
    t.full_name AS teacher_name,
    d.department_name
FROM teachers t
JOIN departments d ON t.department_id = d.department_id

-- LEFT JOIN: Усі студенти та їхні зарахування на курси
SELECT 
    s.full_name AS student_name,
    e.course_id,
    e.status
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id

-- LEFT JOIN: Усі дисципліни та призначені викладачі
SELECT 
    c.course_name,
    ca.teacher_id,
    ca.role_type
FROM courses c
LEFT JOIN course_assignments ca ON c.course_id = ca.course_id

-- RIGHT JOIN: Усі кафедри та викладачі на них
SELECT 
    t.full_name AS teacher_name,
    d.department_name
FROM teachers t
RIGHT JOIN departments d ON t.department_id = d.department_id

-- RIGHT JOIN: Усі факультети та спеціальності
SELECT 
    sp.specialty_name,
    f.faculty_name
FROM specialties sp
RIGHT JOIN faculties f ON sp.faculty_id = f.faculty_id

-- ==========
-- SUBQUERIES
-- ==========

-- Знайти всі курси, у яких кількість кредитів ECTS більша за середній показник серед усіх дисциплін університету
SELECT 
    course_name,
    ects_credits
FROM courses
WHERE ects_credits > (
    SELECT AVG(ects_credits) 
    FROM courses
);

-- Вивести список усіх кафедр та поруч в окремій колонці показати кількість викладачів, які працюють на кожній із них
SELECT 
    d.department_name,
    (
        SELECT COUNT(*) 
        FROM teachers t 
        WHERE t.department_id = d.department_id
    ) AS teachers_count
FROM departments d;