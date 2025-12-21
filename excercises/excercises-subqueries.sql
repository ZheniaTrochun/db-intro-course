-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись

/* це саме важке було, оскільки курс може мати пререквізити, 
які самі мають пререквізити, тут WITH RECURSIVE */

WITH RECURSIVE course_path AS (
    SELECT course_id, 1 as semester
    FROM course
    WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)
    
    UNION ALL
    
    SELECT cp.course_id, cp_path.semester + 1
    FROM course_prerequisite cp
    JOIN course_path cp_path ON cp.prerequisite_course_id = cp_path.course_id
)
SELECT course_id, MAX(semester) as min_possible_semester
FROM course_path
GROUP BY course_id;

-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти

/* у WHERE не можна використовувати агрегатні функції, 
тому спочатку обчислюємо середню кількість записів по університету у підзапиті, 
а потім через HAVING викидаєм студентів, 
у яких власна кількість записів нижча за цей показник. */

SELECT s.name, s.surname, COUNT(e.course_id) as courses_enrolled
FROM student s
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id
HAVING COUNT(e.course_id) > (
    SELECT AVG(counts.cnt) 
    FROM (SELECT COUNT(*) as cnt FROM enrolment GROUP BY student_id) counts
);

-- Знайти топ-3 студенти у кожному курсі за отриманими балами

/* спочатку думала над LIMIT, 
але LIMIT 3 тут не спрацює, 
бо нам потрібно по 3 особи для кожного курсу окремо.
тож далі вибір був між DENSE_RANK І ROW_NUMBER
якщо два студенти мають однакові бали
вони обидва мають займати одне місце
DENSE_RANK не пропускає ранги 
і оцінює однакові результати таким чином справедливо, 
а з ROW_NUMBER так не прокатить */

SELECT course_name, student_name, grade
FROM (
    SELECT 
        c.name as course_name,
        s.name || ' ' || s.surname as student_name,
        e.grade,
        DENSE_RANK() OVER(PARTITION BY c.course_id ORDER BY e.grade DESC) as rank
    FROM enrolment e
    JOIN course c ON e.course_id = c.course_id
    JOIN student s ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
) ranked_students
WHERE rank <= 3;