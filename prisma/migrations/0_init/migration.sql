create table if not exists "user"(
    user_id bigint generated always as identity primary key,
    username varchar(50) not null,
    email varchar(100) not null unique,
    password_hash varchar(128) not null,
    wallet_balance decimal(10, 2) not null default 0.00,
    created_at timestamptz not null default current_timestamp,
    constraint wallet_balance_positive check (wallet_balance >=0)
);

create table if not exists publisher(
    publisher_id int generated always as identity primary key,
    publisher_name varchar(100) unique not null,
    website varchar(2048),
    support_email varchar(100) not null
);

DO $$ BEGIN
    create type app_type as enum ('game', 'dlc');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
create table if not exists app(
    app_id int generated always as identity primary key,
    publisher_id int not null references publisher(publisher_id),
    parent_game_id int references app(app_id),
    title varchar(150) not null unique,
    app_type app_type not null,
    description varchar(4000),
    price decimal(10, 2) not null,
    release_date date not null,
    constraint game_price_positive check(price>=0)
);

create table if not exists category(
    category_id int generated always as identity primary key,
    category_name varchar(50) not null unique,
    description varchar(4000)
);

create table if not exists app_category(
    category_id int not null references category(category_id) on delete cascade,
    app_id int not null references app(app_id) on delete cascade,
    primary key(category_id, app_id)
);

create table if not exists wishlist (
    user_id bigint not null references "user"(user_id) on delete cascade,
    app_id int not null references app(app_id) on delete cascade,
    added_date timestamptz not null default current_timestamp,
    primary key (user_id, app_id)
);

DO $$ BEGIN
    create type payment_method as enum ('credit card', 'google pay', 'apple pay', 'paypal', 'digital wallet');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
DO $$ BEGIN
    create type payment_status as enum ('pending', 'canceled', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

create table if not exists "order" (
    order_id bigint generated always as identity primary key,
    user_id bigint not null,
    receiver_id bigint not null,
    order_date timestamptz not null default current_timestamp,
    total_amount decimal(10, 2) not null,
    payment_method payment_method not null,
    status payment_status not null default 'completed',
    constraint order_amount_positive check (total_amount >= 0)
);

create table if not exists order_item (
    order_id bigint not null references "order"(order_id) on delete cascade,
    app_id int not null,
    price_at_purchase decimal(10, 2) not null,
    primary key (order_id, app_id),
    constraint item_price_positive check (price_at_purchase >= 0)
);

create table if not exists user_library (
    user_id bigint not null references "user"(user_id) on delete cascade,
    app_id int not null references app(app_id) on delete cascade,
    playtime_hours int not null default 0,
    added_date timestamptz not null default current_timestamp,
    primary key (user_id, app_id),
    constraint playtime_non_negative check (playtime_hours >= 0)
);

create table if not exists review (
    review_id bigint generated always as identity primary key,
    user_id bigint not null references "user"(user_id) on delete cascade,
    app_id int not null references app(app_id) on delete cascade,
    is_recommended boolean not null,
    playtime_at_review int not null check(playtime_at_review>=2),
    content varchar(5000),
    created_at timestamptz not null default current_timestamp,
    constraint unique_user_review unique(user_id, app_id)
);


insert into "user" (username, email, password_hash, wallet_balance, created_at)
values 
    ('alex', 'alex@gmail.com', '$2b$12$e8Yk1O1aZ4v7K.uXq9pEteW6vU0tT9oP1u9', 250.01, '2022-01-10 12:30:00+01'),
    ('tina', 'tina@gmail.com', '$2b$12$L7eB1M0oK3y8R.qWp8rYueT5mU9yP8oR2u1', 45.58, '2018-01-14 15:45:00+02'),
    ('max', 'max@gmail.com', '$2b$12$Q4uC9P8mL2x6T.vYo1sXweR8nI4wT3kO9p3', 20.00, '2020-02-01 09:15:00+02'),
    ('sophie', 'sophie@gmail.com', '$2b$12$Y9tX2K5pB1m0W.zUi3aQweP7vO5rE1nK7m5', 0.00, '2017-02-18 18:20:00+02');

insert into publisher (publisher_name, website, support_email)
values
    ('Novas Studios', 'https://novas.com', 'support@novas.com'),
    ('Irons Interactive', 'https://irons-games.com', 'help@irons-games.com'),
    ('Pixerei Games', 'https://pixerei.io', 'contact@pixerei.io');

insert into app (publisher_id, parent_game_id, title, app_type, description, price, release_date)
values
    (1, NULL, 'Shadows of Buntwelt', 'game', 'Tactical squad-based strategy with procedural turn-based combat.', 39.99, '2015-10-06'),
    (2, NULL, 'The Eclipse of Empires', 'game', 'Story-driven open-world Action RPG set in a crumbling sci-fi empire with fluid real-time combat.', 59.99, '2023-05-19'),
    (1, 1, 'Shadows of Buntwelt: The Forgotten Lands', 'dlc', 'Major expansion introducing a new campaign', 14.99, '2018-01-14'),
    (3, NULL, 'Abyssal Trench', 'game', 'Survival simulator challenging players to maintain hull integrity, craft gear, and explore destroyed lands.', 19.99, '2025-08-30');

insert into category (category_name, description)
values
    ('RPG', 'Role-playing games focused on narrative depth and character progression.'),
    ('Strategy', 'Turn-based and real-time tactical planning games.'),
    ('Action', 'Fast-paced titles emphasizing reflexes, movement, and combat.'),
    ('Survival', 'Genre focused on staying alive in a harsh, open world with minimal starting equipment.');

insert into app_category (category_id, app_id)
values
    (1, 2), 
    (3, 2), 
    (2, 1), 
    (2, 3), 
    (4, 4); 

insert into wishlist (user_id, app_id, added_date)
values
    (2, 1, '2026-02-10 14:30:00+02'),
    (2, 3, '2026-02-11 10:15:00+02'),
    (3, 1, '2026-03-01 18:00:00+02'),
    (4, 2, '2026-03-05 21:40:00+02');

insert into "order" (user_id, receiver_id, total_amount, payment_method, status, order_date)
values
    (1, 1, 54.98, 'credit card', 'completed', '2026-02-15 11:20:00+01'),
    (2, 2, 49.99, 'paypal', 'completed', '2026-02-20 16:50:00+02'),
    (3, 3, 19.99, 'google pay', 'completed', '2026-03-02 14:10:00+02'),
    (4, 4, 29.99, 'apple pay', 'completed', '2026-03-10 19:30:00+02');

insert into order_item (order_id, app_id, price_at_purchase)
values
    (1, 1, 39.99),
    (1, 3, 14.99),
    (2, 2, 49.99),
    (3, 4, 19.99),
    (4, 1, 29.99);

insert into user_library (user_id, app_id, playtime_hours, added_date)
values
    (1, 1, 86, '2026-02-15 11:20:05+01'),
    (1, 3, 24, '2026-02-15 11:20:05+01'),
    (2, 2, 142, '2026-02-20 16:50:06+02'),
    (3, 4, 18, '2026-03-02 14:10:04+02'),
    (4, 1, 29, '2026-03-10 19:30:00+02');

insert into review (user_id, app_id, is_recommended, playtime_at_review, content, created_at)
values
    (1, 1, true, 60, 'One of the finest turn-based strategies.', '2026-02-28 20:00:00+01'),
    (1, 3, true, 20, 'Great expansion!', '2026-03-04 15:30:00+01'),
    (2, 2, true, 110, 'Immersive worldbuilding and fluid real-time combat.', '2026-03-05 17:35:00+02');
