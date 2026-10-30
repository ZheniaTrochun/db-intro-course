CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200) NOT NULL
);
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE
);
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE doctor_departments (
    doctor_id INTEGER NOT NULL REFERENCES doctors(doctor_id),
    department_id INTEGER NOT NULL REFERENCES departments(department_id),
    PRIMARY KEY (doctor_id, department_id)
);
CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES patients(patient_id),
    doctor_id INTEGER NOT NULL REFERENCES doctors(doctor_id),
    appointment_date TIMESTAMP NOT NULL,
    appointment_end TIMESTAMP NOT NULL,
    diagnosis TEXT,
    status VARCHAR(50) NOT NULL,
      CHECK (status IN ('Заплановано', 'Завершено', 'Скасовано')),
       CONSTRAINT chk_appointment_time CHECK (appointment_end > appointment_date),
    UNIQUE (patient_id, appointment_date),
    UNIQUE (doctor_id, appointment_date)
);
CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    appointment_id INTEGER NOT NULL REFERENCES appointments(appointment_id),
     type VARCHAR(100) NOT NULL,
     details TEXT,
     status VARCHAR(50) NOT NULL,
     CHECK (status IN ('Заплановано', 'В процесі', 'Завершено', 'Скасовано'))
);

INSERT INTO departments (name, location) VALUES
('Психотерапія', 'Корпус А, 2 поверх'),
('Кардіологія', 'Корпус Б, 3 поверх'),
('Паталогоанатомічне відділення', 'Окремий корпус В, 1 поверх');

INSERT INTO doctors (first_name, last_name, specialization, phone) VALUES
('Олександр', 'Мельник', 'Психотерапевт', '+380971112233'),
('Іван', 'Кравчук', 'Кардіолог', '+380972223344'),
('Андрій', 'Шевченко', 'Патологоанатом', '+380973334455');

INSERT INTO patients (first_name, last_name, date_of_birth, phone, email) VALUES
('Анна', 'Шевчук', '2001-05-23', '+380976542233', 'anna.shevchyk@gmail.com'),
('Ігор', 'Олійник', '2004-03-14', '+380971112435', 'igor.oliynyk@gmail.com'),
('Марія', 'Ткачук', '2005-11-04', '+380973334345', 'maria.tkachyk@gmail.com');

INSERT INTO doctor_departments (doctor_id, department_id) VALUES
(1, 1), 
(2, 2), 
(3, 3);

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_end, diagnosis, status) VALUES
(1, 2, '2026-10-27 10:00:00', '2026-10-27 11:00:00', NULL, 'Заплановано'),
(2, 1, '2026-11-07 12:00:00', '2026-11-07 13:00:00', 'Посттравматичний стресовий розлад', 'Заплановано'),
(3, 3, '2026-10-21 11:00:00', '2026-10-21 12:00:00', 'Посмертна експертиза', 'Завершено');

INSERT INTO treatments (appointment_id, type, details, status) VALUES
(1, 'Консультація', 'Первинний огляд кардіолога та вимірювання тиску', 'Заплановано'),
(2, 'Психотерапія', 'Когнітивно-поведінкова сесія', 'Заплановано'),
(3, 'Розтин/Експертиза', 'Гістологічне дослідження тканин та складання висновку', 'Завершено');