-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
select 	
	e.start_year as student_year,
	round(avg(e.grade), 2) as avg_year_grade
from enrolment e
group by e.start_year
order by e.start_year