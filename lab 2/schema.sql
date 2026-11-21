CREATE TYPE booking_status AS ENUM ('new', 'confirmed', 'completed', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'success', 'failed');

CREATE TABLE client (
    client_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(50) UNIQUE,
    CHECK (phone IS NOT NULL OR email IS NOT NULL)
);

CREATE TABLE court (
    court_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    court_name VARCHAR(15) NOT NULL,
    surface_type VARCHAR(20) NOT NULL CHECK (surface_type IN ('clay', 'hard')),
    is_indoor BOOLEAN NOT NULL DEFAULT FALSE,
    hourly_rate NUMERIC(6, 2) NOT NULL CHECK (hourly_rate > 0)
);

CREATE TABLE coach (
    coach_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    hourly_rate NUMERIC(6, 2) NOT NULL CHECK (hourly_rate > 0)
);

CREATE TABLE equipment (
    equipment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    category VARCHAR(20) NOT NULL,
    rental_price NUMERIC(6, 2) NOT NULL CHECK (rental_price > 0)
);

CREATE TABLE booking (
    booking_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES client (client_id),
    court_id INTEGER NOT NULL REFERENCES court (court_id),
    coach_id INTEGER REFERENCES coach (coach_id),
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL CHECK (end_time > start_time),
    total_price NUMERIC(10, 2) NOT NULL CHECK (total_price > 0),
    status booking_status NOT NULL DEFAULT 'new'
);

CREATE TABLE booking_equipment (
    booking_id INTEGER NOT NULL REFERENCES booking (booking_id),
    equipment_id INTEGER NOT NULL REFERENCES equipment (equipment_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (booking_id, equipment_id)
);

CREATE TABLE payment (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES booking (booking_id),
    payment_date TIMESTAMP NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('card', 'cash')),
    status payment_status NOT NULL DEFAULT 'pending'
);