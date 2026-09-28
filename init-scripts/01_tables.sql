create table if not exists "user"(
    user_id bigint generated always as identity primary key,
    username varchar(50) not null,
    email varchar(100) not null unique,
    password_hash text not null,
    wallet_balance decimal(10, 2) not null default 0.00,
    created_at timestamptz not null default current_timestamp,
    constraint wallet_balance_positive check (wallet_balance >=0)
);

create table if not exists publisher(
    publisher_id int generated always as identity primary key,
    publisher_name varchar(100) unique not null,
    website text,
    support_email varchar(100) not null
);

DO $$ BEGIN
    create type app_type as enum ('game', 'dlc');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
create table if not exists app(
    app_id bigint generated always as identity primary key,
    publisher_id int not null references publisher(publisher_id),
    parent_game_id bigint references app(app_id),
    title varchar(150) not null unique,
    app_type app_type not null,
    description text,
    price decimal(10, 2) not null,
    release_date date not null,
    constraint game_price_positive check(price>=0)
);

create table if not exists category(
    category_id int generated always as identity primary key,
    category_name varchar(50) not null unique,
    description text
);

create table if not exists app_category(
    category_id int not null references category(category_id) on delete cascade,
    app_id bigint not null references app(app_id) on delete cascade,
    primary key(category_id, app_id)
);

create table if not exists wishlist (
    user_id bigint not null references "user"(user_id) on delete cascade,
    app_id bigint not null references app(app_id) on delete cascade,
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
    user_id bigint references "user"(user_id) on delete set null,
    receiver_id bigint references "user"(user_id) on delete set null,
    order_date timestamptz not null default current_timestamp,
    total_amount decimal(10, 2) not null,
    payment_method payment_method not null,
    status payment_status not null default 'completed',
    constraint order_amount_positive check (total_amount >= 0)
);

create table if not exists order_item (
    order_id bigint not null references "order"(order_id) on delete cascade,
    app_id bigint not null references app(app_id),
    price_at_purchase decimal(10, 2) not null,
    primary key (order_id, app_id),
    constraint item_price_positive check (price_at_purchase >= 0)
);

create table if not exists user_library (
    user_id bigint not null references "user"(user_id) on delete cascade,
    app_id bigint not null references app(app_id) on delete cascade,
    playtime_hours int not null default 0,
    added_date timestamptz not null default current_timestamp,
    primary key (user_id, app_id),
    constraint playtime_non_negative check (playtime_hours >= 0)
);

create table if not exists review (
    review_id bigint generated always as identity primary key,
    user_id bigint not null references "user"(user_id) on delete cascade,
    app_id bigint not null references app(app_id) on delete cascade,
    is_recommended boolean not null,
    playtime_at_review int not null check(playtime_at_review>=2),
    content text,
    created_at timestamptz not null default current_timestamp,
    constraint unique_user_review unique(user_id, app_id)
);