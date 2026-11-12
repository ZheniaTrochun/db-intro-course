# Лабораторна робота 3: Маніпулювання даними SQL (OLTP)

## Мета
Метою роботи є опановати практичні навички виконання базових OLTP-операцій маніпулювання даними СУБД PostgreSQL. Реалізувати типові бізнес-сценарії міської бібліотеки (створення, читання, оновлення та видалення записів)

## 1. Операції читання даних

### 1.1. Ідентифікація читача за номером телефону
- Мета: Швидкий пошук читача під час звернення до бібліотеки.

```sql
select reader_id, concat_ws(' ', last_name, first_name, middle_name) full_name, reader_status
from reader
where tel_no = '0987654321';
```
Очікуваний результат: 1 рядок з даними читача. Якщо номер не знайдено - 0 рядків.

Скрін: lab3\tests\1.1.png

### 1.2. Перевірка наявності несплачених штрафів у читача
Мета: Перевірити, чи немає у відвідувача фінансових заборгованостей перед оформленням нової видачі.

```sql
select f.fine_id, r.reader_status, concat_ws(' ', r.last_name, r.first_name, r.middle_name) full_name, f.amount, f.fine_status
from reader r
left join fine f on r.reader_id = f.reader_id and f.fine_status = 'unpaid'
where r.tel_no = '5555555555';
```
Очікуваний результат: Якщо читач має заборгованість - повертається список неоплачених штрафів, якщо заборгованостей немає - рядок з даними читача і NULL у колонках штрафу.

Скрін: lab3\tests\1.2.png

### 1.3. Моніторинг прострочених активних видач
Мета: Сформувати перелік боржників, у яких термін повернення книги минув.

```sql
select loan_id, concat_ws(' ', r.last_name, r.first_name, r.middle_name) full_name, l.start_date, l.end_date, current_date-l.end_date as overdue_days
from loan l
join reader r on l.reader_id = r.reader_id
where l.closed_date is null and l.end_date < current_date; 
```

Очікуваний результат: Список активних видач, плановий термін повернення яких передує поточній даті, із зазначенням кількості днів заборгованості. Закриті видачі до вибірки не потрапляють.

Скрін: lab3\tests\1.3.png

### 1.4. Пошук доступних для видачі примірників конкретного видання
Мета: Знайти фізичні книги на полицях бібліотеки, які не списані та не знаходяться на руках у читачів.

```sql
select c.copy_id, c.barcode, c.copy_condition, i.title, i.isbn
from copy c
join issue i on c.issue_id = i.issue_id
left join loan l on l.copy_id = c.copy_id and l.closed_date is null
where c.copy_condition != 'lost' and l.loan_id is null and i.title = 'The Great Gatsby';
```

Очікуваний результат: Перелік примірників видання 'The Great Gatsby', фізичний стан яких відмінний від 'lost' і для яких немає активного запису у таблиці loan.

Скрін: lab3\tests\1.4.png (немає неактивних)

### 1.5. Перевірка наявності у читача активної видачі примірника видання

Мета: Швидка перевірка бізнес-правила BR-RD-02 перед видачею (читач не може мати одночасно два примірники одного видання).

```sql
select 1
from reader r
join loan l on r.reader_id = l.reader_id
join copy c on l.copy_id = c.copy_id
join issue i on c.issue_id = i.issue_id
where r.tel_no = '0987654321' and i.title = 'The Great Gatsby' and l.closed_date is null;
```
Очікуваний результат: Значення 1, якщо читач уже має на руках незакриту видачу цього видання. Якщо примірник повернено або читач ніколи його не брав - порожній результат

Скрін: lab3\tests\1.5.png

## 2. Операції додавання даних

### 2.1. Реєстрація нового читача з захистом від дублювання

Мета: Зареєструвати нового користувача із запобіганням колізіям за номером телефону та миттєвим отриманням згенерованого ID.

```sql
insert into reader (tel_no, first_name, last_name, middle_name) 
values
('7777777777', 'Michael', 'Johnson', null)
on conflict (tel_no) do nothing returning reader_id, reg_date;
```

Очікуваний результат: Успішне додавання 1 рядка та повернення згенерованого reader_id і поточної дати реєстрації. У разі спроби повторного виконання конфлікт ігнорується, і запит повертає 0 рядків без помилки.

Скрін: lab3\tests\2.1.png

### 2.2. Оформлення видачі книги читачеві з перевіркою бізнес-правил

Мета: Створити запис про видачу без хардкоду сурогатних ID, гарантуючи виконання бізнес-правил BR-RD-01, BR-RD-02 та BR-LN-05.

```sql
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
```

Очікуваний результат: Створення 1 рядка у таблиці loan з поверненням loan_id, start_date та end_date, якщо всі бізнес-правила задоволено. Якщо хоча б одне правило порушене - вставляється 0 рядків без виклику виключень.

Скрін: lab3\tests\2.2.png

### 2.3. Масова реєстрація нових фізичних примірників видань

Мета: Зареєструвати надходження партії фізичних книг до бібліотечного фонду одним запитом.

```sql
insert into copy (issue_id, barcode, copy_condition)
values
(1, 'C020', 'good'),
(1, 'C021', 'normal'),
(2, 'C022', 'good'),
(3, 'C023', 'bad'),
(4, 'C024', 'lost') returning *;
```
Очікуваний результат: Додавання 5 нових примірників із прив'язкою до існуючих issue_id, автогенерацією унікальних copy_id та автоматичним присвоєнням поточної дати реєстрації (current_date).

Скрін: lab3\tests\2.3.png

### 2.4. Нарахування штрафів за порушення правил користування фондом

Мета: Зафіксувати фінансові санкції до читачів за різні типи порушень (прострочення, втрата, пошкодження книги).

```sql
insert into fine (reader_id, loan_id, amount, fine_type, description)
values
(1, 1, 50.00, 'overdue', 'Overdue book'),
(2, 2, 100.00, 'loss', 'Lost book'),
(3, 3, 200.00, 'damage', 'Damaged book') returning *;
```

Очікуваний результат: Створення 3 записів про штрафи зі статусом за замовчуванням 'unpaid', валідацією складеного зовнішнього ключа (loan_id, reader_id) та додатною сумою (amount > 0)

Скрін: lab3\tests\2.4.png

## 3. Операції оновлення даних 

### 3.1. Атомарне повернення примірника читачем

Мета: Зафіксувати факт повернення книги в обліку та синхронізувати фізичний стан примірника (бізнес-правила BR-LN-04, BR-LN-06).

```sql
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
```

Очікуваний результат: Успішне завершення транзакції. У таблиці loan фіксується дата повернення та підсумковий стан примірника (виконується обмеження BR-LN-04). У таблиці copy стан примірника оновлюється на 'good'. Обидва запити повертають змінені значення через returning.

Скрін: lab3\tests\3.1.png

## 4. Операції видалення даних 

### 4.1. Безпечне точкове видалення помилкового штрафу

Мета: Видалити помилково нарахований адміністративний штраф, не прив'язаний до видачі.

```sql
delete from fine
where reader_id = (select reader_id from reader where tel_no = '5555555555')
    and fine_status = 'unpaid' 
    and loan_id is null returning *;
```

Очікуваний результат: Видалення 1 рядка та повернення всіх його атрибутів через returning *. Якщо несплаченого штрафу не знайдено — видаляється 0 рядків.

Скрін: lab3\tests\4.1.png

## Висновки
Під час лабораторної роботи успішно протестовано набір транзакційних OLTP-запитів до розробленої бази даних бібліотеки, продемонстровано роботу розширень PostgreSQL, доведено можливість забезпечення складних бізнес-обмежень безпосередньо в DML-запитах через NOT EXISTS