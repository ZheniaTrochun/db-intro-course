-- Базова аналітика по табилці штрафів

select
    count(*) as total_fines,
    count(*) filter(where loan_id is null) as total_fines_without_loan,
    count(*) filter(where fine_status = 'unpaid') as unpaid_fines,
    count(*) filter(where fine_type = 'overdue') as overdue_fines,
    count(*) filter(where fine_type = 'damage') as damage_fines,
    count(*) filter(where fine_type = 'loss') as loss_fines,
    count(*) filter(where fine_type = 'violation') as violation_fines,
    sum(amount) as total_sum,
    round(avg(amount), 2) as avg_amount,
    min(amount) as min_fine,
    max(amount) as max_fine,
    round(avg(closed_date - start_date), 2) as avg_days
from fine

-- Порахувати кількість активних видач у читача

select
    r.reader_id,
    concat_ws(' ', r.first_name, r.last_name, r.middle_name) as full_name,
    r.tel_no,
    (select count(l.loan_id) from loan l where l.closed_date is null and l.reader_id = r.reader_id) as count_loan
from reader r;


-- Середній строк користування примірниками по виданнях з мінімум двома завершеними видачами сумарно

select 
    i.title,
    round(avg(l.closed_date - l.start_date), 0) as avg_days,
    count(l.closed_date) as loan_count
from issue i
join copy c on i.issue_id = c.issue_id
join loan l on c.copy_id = l.copy_id
where l.closed_date is not null
group by i.issue_id
having count(l.closed_date) >= 2
order by avg_days desc nulls last;

-- знайти кількість примірників, що є на балансі бібліотеки, по виданнях та кількість примірників, які жодного разу не видавалися читачам 

select 
    i.title,
    count(distinct c.copy_id) as copy_count,
    count(c.copy_id) filter(where l.loan_id is null) as copy_without
from issue i
left join copy c on i.issue_id = c.issue_id and copy_condition <> 'lost'
left join loan l on c.copy_id = l.copy_id 
group by i.issue_id

--  Знайти читачів-боржників, у яких сума нарахованих штрафів перевищує середню суму штрафів на читача серед усіх оштрафованих читачів

with sum_fine as(
    select
        r.reader_id,
        concat_ws(' ', first_name, last_name, middle_name) as full_name,
        sum(f.amount) as full_amount,
        coalesce(sum(f.amount) filter(where f.fine_status = 'unpaid'), 0) as unpaid_amount
    from reader r
    join fine f on r.reader_id = f.reader_id
    group by r.reader_id
)
select
    sf.reader_id,
    sf.full_name,
    sf.unpaid_amount as unpaid_amount
from sum_fine sf
where sf.unpaid_amount <> 0 and sf.unpaid_amount > (
    select avg(full_amount)
    from sum_fine
)
order by sf.unpaid_amount desc;

-- Знайти всіх читачів, які брали примірники видань за якимось жанром
select
    r.reader_id,
    concat_ws(' ', first_name, last_name, middle_name) as full_name,
    'Fantasy' as genre
from reader r
where reader_id in(
    select l.reader_id 
    from loan l
    join copy c on c.copy_id = l.copy_id
    join issue i on i.issue_id = c.issue_id
    where i.genre = 'Fantasy'
);

-- Знайти жанри видань, примірники яких читач ще не брав

select
    r.reader_id,
    concat_ws(' ', first_name, last_name, middle_name) as full_name,
    i.genre
from reader r
cross join (select distinct issue.genre from issue where genre is not null) i
where r.reader_status = 'active'
and not exists (
    select 1
    from loan l
    join copy c on c.copy_id = l.copy_id
    join issue i2 on i2.issue_id = c.issue_id
    where l.reader_id = r.reader_id and i.genre = i2.genre
) order by full_name, i.genre asc;

-- Жанри по кількості видач

select 
    i.genre,
    count(l.loan_id) as total_loans
from issue i
left join copy c on i.issue_id = c.issue_id
left join loan l on l.copy_id = c.copy_id
group by i.genre
order by total_loans desc;

-- Знайти для кожного жанру видання з найбільшою кількістю сторінок, знайти, скільки всього видань у цьому жанрі та який середній обсяг сторінок у ньому

with issue_stats as(
    select
        genre,
        title,
        max(pages) over(partition by genre) as max_pages,
        count(issue_id) over(partition by genre) as count_issues,
        avg(pages) over(partition by genre) as avg_pages,
        dense_rank() over(partition by genre order by pages desc) as rank_pages
    from issue
    where genre is not null
)
select 
    genre,
    max_pages,
    title,
    count_issues,
    round(avg_pages, 0) as avg_pages
from issue_stats it
where rank_pages = 1;

-- Знайти авторів без видань у бібліотеці, авторів з виданнями та видання без авторів

select
    coalesce(nullif(concat_ws(' ', c.first_name, c.last_name, c.middle_name, c.pseudonym), ''), 'Автора нема') as full_name,
    coalesce(i.title, 'Немає видань') as title
from creator c
left join issue_creator ic on c.creator_id = ic.creator_id and ic.creator_role = 'author'
full outer join issue i on i.issue_id = ic.issue_id
order by full_name, title;