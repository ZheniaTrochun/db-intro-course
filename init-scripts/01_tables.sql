create table if not exists "user"(
    user_id uuid primary key default gen_random_uuid(),
    username varchar(50) not null,
    email varchar(255) not null unique,
    password_hash varchar(255) not null,
    wallet_balance decimal(10, 2) not null default 0.00,
    created_at timestamptz not null default current_timestamp,
    constraint wallet_balance_positive check (wallet_balance >=0)
);

create table if not exists publisher(
    publisher_id uuid primary key default gen_random_uuid(),
    publisher_name varchar(50) unique not null,
    website varchar(255),
    support_email varchar(100) not null
);

DO $$ BEGIN
    create type app_type as enum ('game', 'dlc');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
create table if not exists app(
    app_id uuid primary key default gen_random_uuid(),
    publisher_id uuid not null references publisher(publisher_id),
    parent_game_id uuid references app(app_id),
    title varchar(150) not null unique,
    app_type app_type not null,
    description text,
    price decimal(10, 2) not null,
    release_date date not null,
    constraint game_price_positive check(price>=0)
);

create table if not exists category(
    category_id uuid primary key default gen_random_uuid(),
    category_name varchar(50) not null unique,
    description text
);

create table if not exists app_category(
    category_id uuid not null references category(category_id) on delete cascade,
    app_id uuid not null references app(app_id) on delete cascade,
    primary key(category_id, app_id)
);

create table if not exists wishlist (
    user_id uuid not null references "user"(user_id) on delete cascade,
    app_id uuid not null references app(app_id) on delete cascade,
    added_date timestamptz not null default current_timestamp,
    primary key (user_id, app_id)
);

DO $$ BEGIN
    create type payment_method as enum ('credit card', 'google pay', 'apple pay', 'paypal', 'digital wallet');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
create table if not exists "order" (
    order_id uuid primary key default gen_random_uuid(),
    user_id uuid references "user"(user_id) on delete set null,
    receiver_id uuid references "user"(user_id) on delete set null,
    order_date timestamptz not null default current_timestamp,
    total_amount decimal(10, 2) not null,
    payment_method payment_method not null,
    status varchar(30) not null default 'completed',
    constraint order_amount_positive check (total_amount >= 0)
);

create table if not exists order_item (
    order_id uuid not null references "order"(order_id) on delete cascade,
    app_id uuid not null references app(app_id),
    price_at_purchase decimal(10, 2) not null,
    primary key (order_id, app_id),
    constraint item_price_positive check (price_at_purchase >= 0)
);

create table if not exists user_library (
    user_id uuid not null references "user"(user_id) on delete cascade,
    app_id uuid not null references app(app_id) on delete cascade,
    playtime_hours int not null default 0,
    added_date timestamptz not null default current_timestamp,
    primary key (user_id, app_id),
    constraint playtime_non_negative check (playtime_hours >= 0)
);

create table if not exists review (
    review_id uuid primary key default gen_random_uuid(),
    user_id uuid not null references "user"(user_id) on delete cascade,
    app_id uuid not null references app(app_id) on delete cascade,
    is_recommended boolean not null,
    playtime_at_review int not null default 0,
    content text,
    created_at timestamptz not null default current_timestamp,
    constraint review_playtime_non_negative check (playtime_at_review >= 0),
    constraint unique_user_review unique(user_id, app_id)
);