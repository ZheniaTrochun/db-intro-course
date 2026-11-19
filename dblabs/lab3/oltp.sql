--select

-- знайти за номером телефону
select reader_id, concat_ws(' ', last_name, first_name, middle_name) full_name, reader_status
from reader
where tel_no = '0987654321';

-- Чи немає у читача несплачених штрафів 
select f.fine_id, r.reader_status, concat_ws(' ', r.last_name, r.first_name, r.middle_name) full_name, f.amount, f.fine_status
from reader r
left join fine f on r.reader_id = f.reader_id and f.fine_status = 'unpaid'
where r.tel_no = '5555555555';

-- Перевірити у кого прострочені активні видачі
select loan_id, concat_ws(' ', r.last_name, r.first_name, r.middle_name) full_name, l.start_date, l.end_date, current_date-l.end_date as overdue_days
from loan l
join reader r on l.reader_id = r.reader_id
where l.closed_date is null and l.end_date < current_date; 

-- Знайти всі примірники конкретного видання, які фізично доступні для видачі
select c.copy_id, c.barcode, c.copy_condition, i.title, i.isbn
from copy c
join issue i on c.issue_id = i.issue_id
left join loan l on l.copy_id = c.copy_id and l.closed_date is null
where c.copy_condition != 'lost' and l.loan_id is null and i.title = 'The Great Gatsby';

-- Чи є у читача активна видача примірника видання
select 1
from reader r
join loan l on r.reader_id = l.reader_id
join copy c on l.copy_id = c.copy_id
join issue i on c.issue_id = i.issue_id
where r.tel_no = '0987654321' and i.title = 'The Great Gatsby' and l.closed_date is null;

--- insert

-- Реєстрація читача
insert into reader (tel_no, first_name, last_name, middle_name) 
values
('7777777777', 'Michael', 'Johnson', null)
on conflict (tel_no) do nothing returning reader_id, reg_date;

-- Видача примірника читачу
insert into loan (reader_id, copy_id, start_date, end_date)
select r.reader_id, c.copy_id, current_date, current_date + interval '14 days'
from reader r
cross join copy c
where r.tel_no = '7777777777' and c.barcode = 'C004' and r.reader_status != 'blocked' and c.copy_condition != 'lost'
and not exists(
    select 1
    from loan l
    join copy c2 on l.copy_id = c2.copy_id
    where l.reader_id = r.reader_id and c2.issue_id = c.issue_id and l.closed_date is null
) and not exists(
    select 1
    from loan l
    where l.copy_id = c.copy_id and l.closed_date is null
) returning loan_id, start_date, end_date;

-- Зареєструвати примірники
insert into copy (issue_id, barcode, copy_condition)
values
(1, 'C020', 'good'),
(1, 'C021', 'normal'),
(2, 'C022', 'good'),
(3, 'C023', 'bad'),
(4, 'C024', 'lost') returning *;

-- Нарахування штрафу
insert into fine (reader_id, loan_id, amount, fine_type, description)
values
(1, 1, 50.00, 'overdue', 'Overdue book'),
(2, 2, 100.00, 'loss', 'Lost book'),
(3, 3, 200.00, 'damage', 'Damaged book') returning *;

--- update

-- Оформлення повернення книги читачем за номером телефону та штрихкодом примірника

begin;

update loan
set
    closed_date = current_date,
    final_condition = 'good'
where reader_id = (select reader_id from reader where tel_no = '+380633334455')
    and copy_id = (select copy_id from copy where barcode = 'C013')
    and closed_date is null returning loan_id, start_date, closed_date;

update copy
set 
    copy_condition = 'good'
where barcode = 'C013' returning copy_id, issue_id, barcode, copy_condition;

commit;

--- delete

--- видалити помилковий штраф

delete from fine
where reader_id = (select reader_id from reader where tel_no = '5555555555')
    and fine_status = 'unpaid' 
    and loan_id is null returning *;
