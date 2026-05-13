-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank) - за балом, іменем студента та ідентифікатором студента
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
SELECT course_name, student_id, student_full_name, grade, rank
from (
SELECT c.name AS course_name, student_id, first_name || ' ' || last_name AS student_full_name, grade, 
	ROW_NUMBER() OVER (
            PARTITION BY c.course_id
            ORDER BY e.grade DESC, p.first_name || ' ' || p.last_name
	) AS rank
from course c
	join enrolment e using(course_id)
	join student s using(student_id)
	join person p using(person_id)
where grade IS NOT NULL
)
where rank <= 5
ORDER BY course_name, rank, student_full_name;