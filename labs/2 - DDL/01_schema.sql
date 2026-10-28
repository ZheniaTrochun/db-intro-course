CREATE TYPE carriage_type AS ENUM ('COUPE', 'PLATZKART', 'LUX', 'SEAT');
--fixed unactive/active status to inactive/active
CREATE TYPE route_status AS ENUM ('ACTIVE', 'INACTIVE');

CREATE TYPE schedule_rule AS ENUM (
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
    'DAILY',
    'WEEKDAYS',
    'WEEKENDS'
);

CREATE TYPE train_type AS ENUM (
    'INTERCITY',
    'REGIONAL',
    'PASSENGER',
    'FAST',
    'FIRM'
);

CREATE TYPE tier_type AS ENUM ('TOP', 'DOWN', 'SEAT');

CREATE TYPE trip_status AS ENUM ('SCHEDULED', 'DEPARTED', 'CANCELLED', 'COMPLETED');

CREATE TYPE ticket_status AS ENUM ('HELD', 'PAID', 'RETURNED', 'EXPIRED');

CREATE TYPE user_role AS ENUM ('PASSENGER', 'ADMIN', 'CONDUCTOR');

CREATE TABLE IF NOT EXISTS stations ( 
        station_id UUID DEFAULT gen_random_uuid(),
        station_name VARCHAR(100) NOT NULL,
        city VARCHAR(50) NOT NULL,

        CONSTRAINT uq_stations_name_city UNIQUE (station_name, city),

        PRIMARY KEY (station_id)
    );

CREATE TABLE IF NOT EXISTS users ( 
        user_id UUID DEFAULT gen_random_uuid(),
        user_name VARCHAR(50) NOT NULL,
        hashed_password VARCHAR(400) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        user_role user_role NOT NULL DEFAULT 'PASSENGER',

        PRIMARY KEY (user_id)
    );

CREATE TABLE IF NOT EXISTS passengers ( 
        passenger_id UUID DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL,
        passenger_lastname VARCHAR(50) NOT NULL,
        passenger_name VARCHAR(50) NOT NULL,
        
        PRIMARY KEY (passenger_id),
        FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS carriage_type_list (
        carriage_type_id UUID DEFAULT gen_random_uuid(),
        carriage_type carriage_type NOT NULL UNIQUE,
        carriage_type_price_multiplier INT NOT NULL DEFAULT 100 
                CHECK (carriage_type_price_multiplier > 0), -- 100 = 1.0x, 150 = 1.5x, 200 = 2.0x
        number_of_seats INT NOT NULL
                CHECK (number_of_seats > 0),

        PRIMARY KEY (carriage_type_id)
    );

CREATE TABLE IF NOT EXISTS routes (
        route_id UUID DEFAULT gen_random_uuid(),
        route_name VARCHAR(100) NOT NULL,
        base_segment_price INT NOT NULL DEFAULT 50
                CHECK (base_segment_price > 0), -- price in kopiyka
        route_number VARCHAR(10) NOT NULL, -- "705K" has a letter, so varchar
        route_status route_status NOT NULL DEFAULT 'INACTIVE',
        schedule_rule schedule_rule NOT NULL,
        train_type train_type NOT NULL DEFAULT 'INTERCITY',

        PRIMARY KEY (route_id)
    );

CREATE TABLE IF NOT EXISTS carriages (
        carriage_id UUID DEFAULT gen_random_uuid(),
        carriage_type_id UUID NOT NULL,
        route_id UUID NOT NULL,
        carriage_number INT NOT NULL
                CHECK (carriage_number > 0),

        CONSTRAINT uq_carriages_route_number UNIQUE (route_id, carriage_number),

        PRIMARY KEY (carriage_id),
        FOREIGN KEY (carriage_type_id) REFERENCES carriage_type_list (carriage_type_id) ON DELETE RESTRICT,
        FOREIGN KEY (route_id) REFERENCES routes (route_id) ON DELETE CASCADE 
    );

CREATE TABLE IF NOT EXISTS seat_templates_list (
        seat_id UUID DEFAULT gen_random_uuid(),
        carriage_type_id UUID NOT NULL,
        seat_number INT NOT NULL
                CHECK (seat_number > 0),
        is_side BOOLEAN NOT NULL,
        tier_type tier_type NOT NULL DEFAULT 'DOWN',

        CONSTRAINT uq_seat_templates_type_number UNIQUE (carriage_type_id, seat_number),

        PRIMARY KEY (seat_id),
        FOREIGN KEY (carriage_type_id) REFERENCES carriage_type_list (carriage_type_id) ON DELETE CASCADE
    );

CREATE TABLE IF NOT EXISTS trips (
        trip_id UUID DEFAULT gen_random_uuid(),
        route_id UUID NOT NULL,
        departure_time TIMESTAMPTZ NOT NULL,
        trip_status trip_status NOT NULL DEFAULT 'SCHEDULED',
        delay_minutes INT NOT NULL DEFAULT 0
                CHECK (delay_minutes >= 0),

        CONSTRAINT uq_trips_route_departure UNIQUE (route_id, departure_time),

        PRIMARY KEY (trip_id),
        FOREIGN KEY (route_id) REFERENCES routes (route_id) ON DELETE RESTRICT
    );

CREATE TABLE IF NOT EXISTS stops (
        stop_id UUID DEFAULT gen_random_uuid(),
        route_id UUID NOT NULL,
        station_id UUID NOT NULL,
        arrival_offset_minutes INT NOT NULL 
                CHECK (arrival_offset_minutes >= 0),
        departure_offset_minutes INT NOT NULL,
        stop_order INT NOT NULL
                CHECK (stop_order > 0),

        CONSTRAINT chk_stops_offsets CHECK (departure_offset_minutes >= arrival_offset_minutes),
        CONSTRAINT uq_stops_route_order   UNIQUE (route_id, stop_order),
        CONSTRAINT uq_stops_route_station UNIQUE (route_id, station_id),

        PRIMARY KEY (stop_id),
        FOREIGN KEY (route_id) REFERENCES routes (route_id) ON DELETE CASCADE,
        FOREIGN KEY (station_id) REFERENCES stations (station_id) ON DELETE RESTRICT
    );

CREATE TABLE IF NOT EXISTS ticket_segment (
        ticket_id UUID DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL,
        passenger_id UUID NOT NULL,
        trip_id UUID NOT NULL,
        seat_id UUID NOT NULL,
        carriage_id UUID NOT NULL,
        from_station_id UUID NOT NULL,
        to_station_id UUID NOT NULL,
        from_stop_order INT NOT NULL,
        to_stop_order INT NOT NULL,

        --state machine
        ticket_status ticket_status NOT NULL DEFAULT 'HELD',
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        hold_expires_at TIMESTAMPTZ DEFAULT (NOW () + INTERVAL '10 minutes'),
        paid_at TIMESTAMPTZ NULL DEFAULT NULL,
        cancelled_at TIMESTAMPTZ NULL DEFAULT NULL,

        --money
        price INT NOT NULL CHECK (price > 0),
        payment_transaction_id TEXT UNIQUE DEFAULT NULL, -- NULLs allowed; real values must be unique (idempotency)
        pdf_url TEXT NULL, --link to S3 bucket

        -- snapshot: frozen copies, never read from live tables for a PAID ticket
        passenger_lastname VARCHAR(50) NOT NULL,
        passenger_name VARCHAR(50) NOT NULL,
        from_station_name VARCHAR(100) NOT NULL,
        to_station_name VARCHAR(100) NOT NULL,
        departure_time TIMESTAMPTZ NOT NULL,
        arrival_time TIMESTAMPTZ NOT NULL,

        -- FOR CONDUCTOR 
        boarded_at TIMESTAMPTZ NULL DEFAULT NULL,
        
        CONSTRAINT chk_ticket_stop_order CHECK (from_stop_order < to_stop_order),
        CONSTRAINT chk_ticket_times      CHECK (arrival_time > departure_time),
        CONSTRAINT chk_ticket_stations   CHECK (from_station_id <> to_station_id),

        PRIMARY KEY (ticket_id),
        FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT,
        FOREIGN KEY (passenger_id) REFERENCES passengers (passenger_id) ON DELETE RESTRICT,
        FOREIGN KEY (trip_id) REFERENCES trips (trip_id) ON DELETE RESTRICT,
        FOREIGN KEY (carriage_id) REFERENCES carriages (carriage_id) ON DELETE RESTRICT,
        FOREIGN KEY (seat_id) REFERENCES seat_templates_list (seat_id) ON DELETE RESTRICT,
        FOREIGN KEY (from_station_id) REFERENCES stations (station_id) ON DELETE RESTRICT,
        FOREIGN KEY (to_station_id) REFERENCES stations (station_id) ON DELETE RESTRICT
        -- we should add index to not allow holding simutaniosly for one person
        -- we should add index to prevent situations from_stop_order > to_stop_order
    );