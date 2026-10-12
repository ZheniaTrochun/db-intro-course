DROP TABLE IF EXISTS property,
property_owner,
TENANT,
APPLICATION,
REALTOR,
LEASE_AGREEMENT CASCADE;
CREATE TABLE PROPERTY_OWNER (owner_id);
INT generated always as identity PRIMARY KEY,
full_name VARCHAR(100) not null,
phone_number VARCHAR(20) not null unique,
passport_data VARCHAR(20) not null unique CREATE TABLE PROPERTY (
    property_id INT generated always as identity PRIMARY KEY,
    owner_id INT not null,
    adress VARCHAR(80) not null unique,
    FOREIGN KEY (owner_id) REFERENCES PROPERTY_OWNER(owner_id)
);
CREATE TABLE TENANT (tenant_id INT PRIMARY KEY);
CREATE TABLE REALTOR (realtor_id INT PRIMARY KEY);
CREATE TABLE APPLICATION (application_id INT PRIMARY KEY);
CREATE TABLE LEASE_AGREEMENT (lease_id INT PRIMARY KEY);
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