# Лабораторна робота 4: Аналітичні SQL-запити (OLAP)

## Мета
Опанувати практичні навички побудови складних аналітичних SQL-запитів до реляційної бази даних у PostgreSQL. Навчитись використовувати агрегатні функції з фільтрацією, різні види операцій JOIN, вкладені підзапити, CTE та віконні функції для формування бізнес-звітності бібліотеки.


## 1. Базова аналітика фінансових нарахувань за штрафами
Мета: Сформувати комплексну фінансову звітність за всіма штрафами бібліотеки за один прохід по таблиці. Це сукупний обсяг нарахувань, середній, мінімальний та максимальний розмір стягнення, середній термін врегулювання закритих штрафів, а також розподіл нарахувань за категоріями порушень та статусом оплати.
SQL-запит:
```SQL
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
from fine;
```
Очікуваний результат: 1 рядок зведеної статистики. 
Скріншот виконання: lab4\tests\1.png

## 2. Середній строк користування книгами з відсіканням малоактивних видань
Мета: Розрахувати середню фактичну тривалість перебування примірників на руках у читачів для тих видань, за якими накопичено достатню статистичну вибірку у 2 завершені видачі.
SQL-запит:
```SQL
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
```
Очікуваний результат: Список видань, відсортований за спаданням середнього терміну читання.
Скріншот виконання: lab4\tests\2.png

## 3. Облік фізичного фонду та частка невитребуваних примірників
Мета: Для кожного бібліографічного видання порахувати кількість діючих фізичних примірників на балансі,виключаючи списані зі статусом lost, та визначити кількість книг, які ще жодного разу не бралися читачами.
SQL-запит:
```SQL
select 
    i.title,
    count(distinct c.copy_id) as copy_count,
    count(c.copy_id) filter(where l.loan_id is null) as copy_without
from issue i
left join copy c on i.issue_id = c.issue_id and copy_condition <> 'lost'
left join loan l on c.copy_id = l.copy_id 
group by i.issue_id;
```
Очікуваний результат: Повний перелік видань із двома метриками фонду.
Скріншот виконання: lab4\tests\3.png

## 4. Рейтинг популярності жанрів за кількістю видач
Мета: Згрупувати видачі за жанрами літератури та вивести рейтинг читацького попиту, включно з жанрами, за якими ще не було зареєстровано жодного факту видачі.
SQL-запит:
```SQL
select 
    i.genre,
    count(l.loan_id) as total_loans
from issue i
left join copy c on i.issue_id = c.issue_id
left join loan l on l.copy_id = c.copy_id
group by i.genre
order by total_loans desc;
```
Очікуваний результат: Список жанрів зі спадним сортуванням за кількістю фактів користування.
Скріншот виконання: lab4\tests\4.png

## 5. Формування таблиці жанрів для рекомендації
Мета: Скласти для кожного активного читача перелік доступних у бібліотеці жанрів, літературу з яких він ще жодного разу не замовляв.
SQL-запит:
```SQL
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
) 
order by full_name, i.genre asc;
```
Очікуваний результат: Повний перелік комбінацій "читач - жанр, що він не брав".
Скріншот виконання: lab4\tests\5.png

## 6. Автори та видання
Мета: Сформувати таблицю, виявивши зареєстрованих авторів без закріплених видань у фонді, бібліографічні видання без зазначеного авторства та повноцінно заповнені пари.
SQL-запит:
```SQL
select
    coalesce(nullif(concat_ws(' ', c.first_name, c.last_name, c.middle_name, c.pseudonym), ''), 'Автора нема') as full_name,
    coalesce(i.title, 'Немає видань') as title
from creator c
left join issue_creator ic on c.creator_id = ic.creator_id and ic.creator_role = 'author'
full outer join issue i on i.issue_id = ic.issue_id
order by full_name, title;
```
Очікуваний результат: Двостороння вибірка, яка об'єднує дані також за відсутності відповідностей з одного з боків
Скріншот виконання: lab4\tests\6.png

## 7. Розрахунок навантаження читачів
Мета: Сформувати список читачів із зазначенням точної кількості примірників, які перебувають у них на руках прямо зараз.
SQL-запит:
```SQL
select
    r.reader_id,
    concat_ws(' ', r.first_name, r.last_name, r.middle_name) as full_name,
    r.tel_no,
    (select count(l.loan_id) from loan l where l.closed_date is null and l.reader_id = r.reader_id) as count_loan
from reader r;
```
Очікуваний результат: Реєстр усіх читачів із колонкою count_loan.
Скріншот виконання: lab4\tests\7.png

## 8. Розподіл читачів за жанровими вподобаннями
Мета: Отримати контактні дані читачів, які проявляли інтерес до літератури жанру 'Fantasy'.
SQL-запит:
```SQL
select
    r.reader_id,
    concat_ws(' ', first_name, last_name, middle_name) as full_name,
    'Fantasy' as genre
from reader r
where reader_id in (
    select l.reader_id 
    from loan l
    join copy c on c.copy_id = l.copy_id
    join issue i on i.issue_id = c.issue_id
    where i.genre = 'Fantasy'
);
```
Очікуваний результат: Список унікальних читачів-шанувальників фентезі.
Скріншот виконання: lab4\tests\8.png

## 9. Виявлення злісних боржників
Мета: Знайти читачів із непогашеною заборгованістю, сума активного боргу яких перевищує середній розмір сукупних нарахувань на одного оштрафованого відвідувача за всю історію спостережень.
SQL-запит:
```SQL
with sum_fine as (
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
where sf.unpaid_amount <> 0 
  and sf.unpaid_amount > (
      select avg(full_amount)
      from sum_fine
  )
order by sf.unpaid_amount desc;
```
Очікуваний результат: Список критичних боржників бібліотеки.
Скріншот виконання: lab4\tests\9.png

## 10. Аналіз жанрових обсягів
Мета: Для кожного літературного жанру знайти видання з найбільшою кількістю сторінок, вивести розраховану для цього ж жанру загальну кількість книг та середній обсяг сторінок.
SQL-запит:
```SQL
with issue_stats as (
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
```
Очікуваний результат: Таблиця лідерів за обсягом у кожному жанрі.
Скріншот виконання: lab4\tests\10.png

## Висновки
Під час виконання лабораторної роботи було реалізовано 10 аналітичних запитів, досліджено різницю між OLTP та OLAP, успішно релізовано агрегатні обчислення, групування, фільтрація, реалізовано запити з різним типом з'єднань для консолідації даних та використано підзапити різної складності.