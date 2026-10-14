DROP TABLE IF EXISTS property,
property_owner,
TENANT,
APPLICATION,
REALTOR,
LEASE_AGREEMENT CASCADE;
CREATE TABLE PROPERTY_OWNER (
    owner_id INT generated always as identity PRIMARY KEY,
    full_name VARCHAR(100) not null unique,
    phone_number VARCHAR(20) not null unique,
    passport_data VARCHAR(20) not null unique
);
CREATE TABLE PROPERTY (
    property_id INT generated always as identity PRIMARY KEY,
    owner_id INT not null,
    adress VARCHAR(80) not null unique,
    FOREIGN KEY (owner_id) REFERENCES PROPERTY_OWNER(owner_id)
);
CREATE TABLE TENANT (
    tenant_id INT generated always as identity PRIMARY KEY,
    full_name VARCHAR(100) not null,
    phone_number VARCHAR(20) not null unique
);
CREATE TABLE REALTOR (
    realtor_id INT generated always as identity PRIMARY KEY,
    full_name VARCHAR(100) not null,
    phone_number VARCHAR(20) not null unique,
    commission_rate DECIMAL(4, 2) not null CHECK (commission_rate >= 0)
);
INSERT INTO property_owner (full_name, phone_number, passport_data)
VALUES (
        'Іваненко Іван Іванович',
        '+380971234567',
        'АМ123456'
    ),
    (
        'Петренко Олена Василівна',
        '+380509876543',
        '001234567'
    ),
    (
        'Коваленко Андрій Сергійович',
        '+380631112233',
        'КБ987654'
    );
INSERT INTO property (owner_id, adress)
VALUES (1, 'м. Київ, вул. Хрещатик, буд. 10, кв. 5'),
    (
        1,
        'м. Київ, вул. Лесі Українки, буд. 14, кв. 80'
    ),
    (2, 'м. Львів, вул. Городоцька, буд. 25, кв. 12'),
    (3, 'м. Одеса, вул. Дерибасівська, буд. 1, кв. 3');
INSERT INTO TENANT (full_name, phone_number)
VALUES ('Сидоренко Максим Петрович', '+380674445566'),
    ('Гончар Анна Ігорівна', '+380505556677'),
    ('Мельник Дмитро Олегович', '+380931239876');
INSERT INTO REALTOR (full_name, phone_number, commission_rate)
VALUES ('Дмитренко Олег Олегович', '+380637778899', 5.00),
    (
        'Ковальчук Світлана Миколаївна',
        '+380978889900',
        4.50
    ),
    ('Павлюк Марина Сергіївна', '+380501112233', 4.00);
CREATE TABLE APPLICATION (
    application_id INT PRIMARY KEY,
    tenant_id INT not null,
    property_id INT not null,
    submission_date DATE not null,
    status VARCHAR(20) not null CHECK (status IN ('в обробці', 'схвалено', 'відхилено')),
    FOREIGN KEY (tenant_id) REFERENCES TENANT(tenant_id),
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id)
);
CREATE TABLE LEASE_AGREEMENT (
    lease_id INT PRIMARY KEY,
    property_id INT not null,
    tenant_id INT not null,
    realtor_id INT,
    start_date DATE not null,
    end_date DATE not null CHECK (end_date > start_date),
    rental_amount DECIMAL(12, 2) not null CHECK (rental_amount > 0),
    agency_commission DECIMAL(12, 2) not null CHECK (agency_commission > 0),
    FOREIGN KEY (property_id) REFERENCES PROPERTY(property_id),
    FOREIGN KEY (tenant_id) REFERENCES TENANT(tenant_id),
    FOREIGN KEY (realtor_id) REFERENCES REALTOR(realtor_id)
);
INSERT INTO APPLICATION (application_id, tenant_id, property_id, submission_date, status)
VALUES (1, 1, 1, '2026-09-01', 'схвалено'),
    (2, 2, 2, '2026-09-03', 'схвалено'),
    (3, 3, 3, '2026-09-05', 'в обробці'),
    (4, 1, 4, '2026-09-07', 'схвалено');
INSERT INTO LEASE_AGREEMENT (lease_id, property_id, tenant_id, realtor_id, start_date, end_date, rental_amount, agency_commission)
VALUES (1, 1, 1, 1, '2026-10-01', '2027-09-30', 15000.00, 750.00),
    (2, 2, 2, 2, '2026-10-05', '2027-04-05', 12000.00, 540.00),
    (3, 4, 1, 3, '2026-11-01', '2027-10-31', 18000.00, 720.00);