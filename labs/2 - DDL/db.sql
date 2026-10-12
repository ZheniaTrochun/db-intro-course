DROP TABLE IF EXISTS property,
property_owner,
TENANT,
APPLICATION,
REALTOR,
LEASE_AGREEMENT CASCADE;

CREATE TABLE PROPERTY_OWNER (
    owner_id INT generated always as identity PRIMARY KEY,
    full_name VARCHAR(100) not null,
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
    commission_rate DECIMAL(4,2) not null CHECK (commission_rate >= 0)
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
VALUES 
    ('Сидоренко Максим Петрович', '+380674445566'),
    ('Гончар Анна Ігорівна', '+380505556677'),
    ('Мельник Дмитро Олегович', '+380931239876');

INSERT INTO REALTOR (full_name, phone_number, commission_rate)
VALUES 
    ('Дмитренко Олег Олегович', '+380637778899', 5.00),
    ('Ковальчук Світлана Миколаївна', '+380978889900', 4.50),
    ('Павлюк Марина Сергіївна', '+380501112233', 4.00);
CREATE TABLE APPLICATION (application_id INT PRIMARY KEY);
CREATE TABLE LEASE_AGREEMENT (lease_id INT PRIMARY KEY);
