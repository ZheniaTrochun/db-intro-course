-- --------------------------------------------------------------------
-- 1. ВИБІРКА ДАНИХ (SELECT)
-- --------------------------------------------------------------------

-- 1.1 Отримання списку студентів з конкретної групи (group_id = 1)
SELECT student_id, full_name, email 
FROM students 
WHERE group_id = 1;

-- 1.2 Отримання викладачів зі званням Професор або Доцент
SELECT teacher_id, full_name, academic_rank, department_id
FROM teachers 
WHERE academic_rank IN ('Professor', 'Associate Professor');

-- 1.3 Перегляд усіх активних зарахувань на 2-й семестр
SELECT enrollment_id, student_id, course_id, status 
FROM enrollments 
WHERE semester = 2 AND status = 'Active';

-- 1.4 Перегляд оцінок з журналу за першу лабораторну роботу
SELECT grade_id, enrollment_id, teacher_id, score, work_type, grade_date
FROM grade_records 
WHERE work_type = 'Лабораторна робота №1';


-- --------------------------------------------------------------------
-- 2. ЗМІНА ДАНИХ (UPDATE)
-- --------------------------------------------------------------------

-- 2.1 Оновлення вченого звання та пошти викладача (teacher_id = 4)
UPDATE teachers 
SET academic_rank = 'Senior Lecturer', 
    email = 'shevchenko.t.new@kpi.ua'
WHERE teacher_id = 4;

-- Перевірка змінених даних викладача
SELECT teacher_id, full_name, email, academic_rank 
FROM teachers 
WHERE teacher_id = 4;

-- 2.2 Встановлення підсумкової оцінки та успішного завершення курсу студентом
UPDATE enrollments 
SET final_grade = 92, 
    status = 'Completed'
WHERE student_id = 1 AND course_id = 2 AND status = 'Active';

-- Перевірка результату оновлення зарахування
SELECT enrollment_id, student_id, course_id, final_grade, status 
FROM enrollments 
WHERE student_id = 1 AND course_id = 2;


-- --------------------------------------------------------------------
-- 3. ВИДАЛЕННЯ ДАНИХ (DELETE)
-- --------------------------------------------------------------------

-- 3.1 Видалення конкретного запису з журналу оцінок (grade_id = 5)
DELETE FROM grade_records 
WHERE grade_id = 5;

-- Перевірка видалення оцінки
SELECT grade_id, enrollment_id, score 
FROM grade_records 
WHERE grade_id = 5;

-- 3.2 Безпечне видалення зарахування студента (з дотриманням ON DELETE RESTRICT)
-- Крок А: Видаляємо пов'язані оцінки з grade_records для enrollment_id = 4
DELETE FROM grade_records 
WHERE enrollment_id = 4;

-- Крок Б: Видаляємо сам запис із enrollments
DELETE FROM enrollments 
WHERE enrollment_id = 4;

-- Перевірка відсутності запису в enrollments
SELECT enrollment_id, student_id, course_id 
FROM enrollments 
WHERE enrollment_id = 4;