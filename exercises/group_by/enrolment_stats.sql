-- Завдання:
--      Порахувати статистику записів на курси для кожного року запису на курс
--      Очікувані колонки результату:
--          - рік запису на курс (enrolment_year) - рік з enrolment.created_at
--          - кількість курсів (number_of_courses)
--          - кількість записів (number_of_enrolments)
--          - кількість записів з виставленою оцінкою (number_of_graded_enrolments)
--      Результат відсортувати за:
--          - роком запису на курс (зростання)

-- Рішення:

select 
    extract(year from e.created_at) 			as enrolment_year,
    count(distinct e.course_id)     			as number_of_courses,
    count(*)                        			as number_of_enrolments,
    count(*) filter (where e.grade is not null) as number_of_graded_enrolments
from enrolment e
group by extract(year from e.created_at)
order by enrolment_year asc;
