-- порахувати успішність студентів залежно від року навчання
 
/* через GROUP BY,
фільтр WHERE grade IS NOT NULL потрібен, 
щоб не псувати середній бал нульовими значеннями 
студентів, які ще не склали іспит,
round бо там вилазило багато цифр після коми */

SELECT 
    c.student_year, 
    ROUND(AVG(e.grade), 2) as avg_grade
FROM enrolment e
JOIN course c ON e.course_id = c.course_id
WHERE e.grade IS NOT NULL
GROUP BY c.student_year
ORDER BY c.student_year;

-- для кожного з студентів знайти його середній бал у порівнянні з середнім балом по групі

/* прийшла до висновку: 
віконні функції саме в цьому випадку виглядають чистіше
варто було прийти раніше, але я хотіла спатки 
тож тримайте цілих два способи, один з яких шакальний */

/* 
обчислюємо середні значення у двох окремих підзапитах 
і потім поєднуємо їх з основною таблицею 
*/

WITH student_stats AS (
    SELECT 
        student_id, 
        AVG(grade) as avg_personal
    FROM enrolment
    WHERE grade IS NOT NULL
    GROUP BY student_id
),
group_stats AS (
    SELECT 
        s.group_id, 
        AVG(e.grade) as avg_group
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY s.group_id
)
SELECT 
    s.name, 
    s.surname,
    sg.name as group_name,
    ROUND(ss.avg_personal, 2) as student_avg,
    ROUND(gs.avg_group, 2) as group_avg
FROM student s
JOIN student_group sg ON s.group_id = sg.group_id
LEFT JOIN student_stats ss ON s.student_id = ss.student_id
LEFT JOIN group_stats gs ON s.group_id = gs.group_id;

-- нормальна реалізація: 

SELECT 
    s.name, 
    s.surname,
    sg.name as group_name,
    ROUND(AVG(e.grade) OVER(PARTITION BY s.student_id), 2) as student_avg,
    ROUND(AVG(e.grade) OVER(PARTITION BY s.group_id), 2) as group_avg
FROM student s
JOIN student_group sg ON s.group_id = sg.group_id
LEFT JOIN enrolment e ON s.student_id = e.student_id
WHERE e.grade IS NOT NULL;

-- як бачимо виглядає чисто, і зрозуміло, навідміну від попереднього whatever it was


-- порахувати статистику записів на курси для кожного року навчання:
--      кількість курсів
--      кількість записів
--      кількість студентів, що вже отримали бали

SELECT 
    c.student_year,
    COUNT(DISTINCT c.course_id) as courses_count, -- рахує унікальні курси для цього року.
    COUNT(e.student_id) as total_enrolments, -- рахує загальну кількість записів (включаючи тих, хто ще без оцінки)
    COUNT(e.grade) as graded_enrolments -- автоматично ігнорує NULL, що підходить для підрахунку "вже оцінених" робіт без дод. умов
FROM course c
LEFT JOIN enrolment e ON c.course_id = e.course_id
GROUP BY c.student_year;