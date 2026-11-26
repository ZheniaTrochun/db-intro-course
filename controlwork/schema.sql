create type user_role_enum as enum ('buyer', 'seller', 'admin');
create type user_status as enum ('active', 'deleted', 'banned');
create type lot_status as enum ('active', 'bought', 'deleted', 'ended');
create type bet_status as enum ('active', 'deleted', 'ended', 'won');
create type transaction_status as enum ('pending', 'completed', 'cancelled');

create table "user" (
id int generated always as identity primary key,
username varchar(20) unique not null,
email varchar(100) unique not null,
hashed_password text not null,
name varchar(50) not null,
status user_status default 'active'
);

create table user_role (
id int generated always as identity primary key,
user_id int references "user"(id) on delete cascade not null,
role user_role_enum not null
);

create table lot (
id int generated always as identity primary key,
name varchar(30) not null,
description varchar(200),
user_id int references "user"(id) on delete cascade not null,
start_price decimal(10,2) not null,
currency varchar(20) not null,
created_at timestamp default now() not null,
end_time timestamp,
status lot_status default 'active'
);

create table bet (
id int generated always as identity primary key,
user_id int references "user"(id) on delete cascade not null,
lot_id int references lot(id) on delete cascade not null,
amount decimal(10,2) not null,
created_at timestamp not null default now(),
status bet_status default 'active'
);

create table category (
id int generated always as identity primary key,
name varchar(30) unique not null
);

create table lot_category (
lot_id int references lot(id) on delete cascade not null,
category_id int references category(id) on delete cascade not null,
primary key (lot_id, category_id)
);

create table transaction(
id int generated always as identity primary key,
buyer_id int references "user"(id) not null,
seller_id int references "user"(id) not null,
lot_id int references lot(id) not null,
bet_id int references bet(id) not null,
created_at timestamp default now() not null,
amount decimal(10,2) not null,
currency varchar(20) not null,
status transaction_status default 'pending'
);