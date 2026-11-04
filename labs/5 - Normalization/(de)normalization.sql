-- Порушення 1NF: масив категорій замість окремої таблиці 
alter table app add column categories varchar(100);
update app set categories = array['Strategy', 'Tactics'] where app_id = 1;
update app set categories = array['RPG', 'Action'] where app_id = 2;
drop table if exists app_category;
select * from app where app_id in(1,2)
-- Відновлення
create table if not exists app_category(
    category_id int not null references category(category_id) on delete cascade,
    app_id bigint not null references app(app_id) on delete cascade,
    primary key(category_id, app_id)
);
insert into app_category (category_id, app_id)
values
    (1, 2), 
    (3, 2), 
    (2, 1), 
    (2, 3), 
    (4, 4); 
alter table app drop column categories;

--Порушення 2NF: часткова функціональна залежність у складеному ключі
alter table order_item add column app_title varchar(150);
update order_item oi
set app_title = a.title
from app a
where oi.app_id = a.app_id;
-- Відновлення
alter table order_item drop column app_title;

--Порушення 3NF: внесення атрибутів видавця в таблицю app
alter table app add column publisher_name varchar(100);
alter table app add column publisher_website varchar(500);
alter table app add column publisher_support_email varchar(100);
update app a
set publisher_name = p.publisher_name,
    publisher_website = p.website,
    publisher_support_email = p.support_email
from publisher p
where a.publisher_id = p.publisher_id;
select * from app;
drop table if exists publisher;
-- Відновлення
create table if not exists publisher(
    publisher_id int generated always as identity primary key,
    publisher_name varchar(100) unique not null,
    website varchar(2048),
    support_email varchar(100) not null
);
insert into publisher (publisher_name, website, support_email)
select distinct publisher_name, publisher_website, publisher_support_email
from app
where publisher_name is not null
on conflict (publisher_name) do nothing;
alter table app drop column publisher_name;
alter table app drop column publisher_website;
alter table app drop column publisher_support_email;