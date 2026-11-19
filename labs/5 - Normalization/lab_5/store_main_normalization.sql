drop table if exists order_product, orders, payment_data, address, product, customer cascade;
drop type if exists card_type_enum, shipping_method_enum, order_status_enum cascade;

create type card_type_enum as enum ('Visa', 'Mastercard');
create type shipping_method_enum as enum ('Нова Пошта', 'Укрпошта', 'Самовивіз', 'Кур''єр');
create type order_status_enum as enum ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled');

create table customer (
    customer_id    integer generated always as identity primary key,
    name           varchar(255) not null,
    email          varchar(255) not null
        check (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    password_hash  varchar(255) not null, -- хешування на рівні бекенду
    phone          varchar(20)  not null,
    deleted_at     timestamp null
);

create unique index uq_customer_email on customer (lower(email)) where deleted_at is null;

create table address (
    address_id   integer generated always as identity primary key,
    customer_id  integer not null references customer(customer_id) on delete restrict,
    street       varchar(255) not null,
    city         varchar(100) not null,
    is_default   boolean not null default false,
    deleted_at   timestamp null,
    constraint uq_address_customer unique (address_id, customer_id)
);

create unique index ux_address_one_default
    on address (customer_id) where is_default and deleted_at is null;

create table payment_data (
    payment_data_id  integer generated always as identity primary key,
    customer_id      integer not null references customer(customer_id) on delete restrict,
    card_type        card_type_enum not null,
    card_mask        varchar(20) not null
        check (card_mask ~ '^\*{4} \*{4} \*{4} [0-9]{4}$'),
    expiration_date  varchar(5) not null
        check (expiration_date ~ '^(0[1-9]|1[0-2])/[0-9]{2}$'),
    is_default       boolean not null default false,
    deleted_at       timestamp null,
    constraint uq_payment_customer unique (payment_data_id, customer_id)
);

create unique index ux_payment_one_default
    on payment_data (customer_id) where is_default and deleted_at is null;

create table product (
    product_id      integer generated always as identity primary key,
    name            varchar(255) not null,
    description     text,
    price           numeric(12, 2) not null check (price > 0),
    stock_quantity  integer not null default 0 check (stock_quantity >= 0),
    deleted_at      timestamp null
);

create table orders (
    order_id             integer generated always as identity primary key,
    customer_id          integer not null references customer(customer_id) on delete restrict,
    payment_data_id      integer not null,
    shipping_address_id  integer not null,
    shipping_method      shipping_method_enum not null,
    order_date           timestamp not null default now(),
    status               order_status_enum not null default 'Pending',
    foreign key (shipping_address_id, customer_id)
        references address(address_id, customer_id) on delete restrict,
    foreign key (payment_data_id, customer_id)
        references payment_data(payment_data_id, customer_id) on delete restrict
);

create table order_product (
    order_id           integer not null references orders(order_id) on delete restrict,
    product_id         integer not null references product(product_id) on delete restrict,
    quantity           integer not null check (quantity > 0),
    price_at_purchase  numeric(12, 2) not null check (price_at_purchase > 0),
    primary key (order_id, product_id) -- один товар = один рядок
);