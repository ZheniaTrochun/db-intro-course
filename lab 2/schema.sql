CREATE TABLE client (
    client_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    CHECK (phone IS NOT NULL OR email IS NOT NULL)
);

create table court (
    court_id int generated always as identity primary key,
    court_name varchar(100) not null,
    surface_type varchar(20) not null,
    is_indoor boolean not null default false,
    hourly_rate numeric(10, 2) not null check (hourly_rate > 0)
);

create table coach (
    coach_id int generated always as identity primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    phone varchar(20) not null unique,
    hourly_rate numeric(10, 2) not null check (hourly_rate > 0)
);

create table equipment (
    equipment_id int generated always as identity primary key,
    item_name varchar(100) not null,
    category varchar(20) not null,
    rental_price numeric(10, 2) not null check (rental_price > 0)
);

create table booking (
    booking_id int generated always as identity primary key,
    client_id int not null references client (client_id),
    court_id int not null references court (court_id),
    coach_id int references coach (coach_id),
    booking_date date not null,
    start_time time not null,
    end_time time not null check (end_time > start_time),
    total_price numeric(10, 2) not null check (total_price > 0),
    status varchar(20) not null default 'new'
);

create table booking_equipment (
    booking_id int not null references booking (booking_id),
    equipment_id int not null references equipment (equipment_id),
    quantity int not null check (quantity > 0),
    primary key (booking_id, equipment_id)
);

create table payment (
    payment_id int generated always as identity primary key,
    booking_id int not null references booking (booking_id),
    payment_date timestamp not null,
    amount numeric(10, 2) not null check (amount > 0),
    payment_method varchar(20) not null,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'success', 'failed'))
);