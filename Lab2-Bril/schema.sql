
CREATE TYPE car_status AS ENUM ('available', 'rented', 'maintenance', 'unavailable');
CREATE TYPE rental_status AS ENUM ('active', 'finished', 'cancelled', 'scheduled');
CREATE TYPE payment_status AS ENUM ('paid', 'cancelled', 'pending_confirmation');

CREATE TABLE customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(100) NOT NULL
);

CREATE TABLE car_model (
    car_model_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    daily_rate NUMERIC(10, 2) NOT NULL CHECK (daily_rate >= 0)
);

CREATE TABLE car (
    car_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    car_model_id INT NOT NULL REFERENCES car_model(car_model_id),
    status car_status NOT NULL DEFAULT 'available'
);

CREATE TABLE rental (
    rental_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id),
    car_id INT NOT NULL REFERENCES car(car_id),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL CHECK (end_date > start_date),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    status rental_status NOT NULL DEFAULT 'scheduled'
);

CREATE TABLE payment (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rental_id INT NOT NULL REFERENCES rental(rental_id),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP NOT NULL,
    status payment_status NOT NULL DEFAULT 'pending_confirmation'
);