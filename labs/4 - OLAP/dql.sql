-------------------------------------------------дозаповнення таблиць для більшої наглядності 

INSERT INTO property_owner (full_name, phone_number, passport_data) VALUES
('Шевченко Тарас Григорович', '+380671112234', 'АМ654321'),
('Бойко Марія Петрівна', '+380502223344', '009876543'),
('Мельниченко Василь Павлович', '+380933334455', 'КБ123789'),
('Гнатюк Оксана Володимирівна', '+380634445567', 'АМ998877'),
('Козак Петро Степанович', '+380975556688', '005544332'),
('Лисенко Катерина Іванівна', '+380506667799', 'КБ445566'),
('Кравченко Максим Юрійович', '+380677778800', 'АМ112233');

INSERT INTO PROPERTY (owner_id, adress) VALUES
(2, 'м. Львів, вул. Свободи, буд. 8, кв. 3'),
(4, 'м. Київ, вул. Велика Васильківська, буд. 50, кв. 14'),
(5, 'м. Одеса, вул. Рішельєвська, буд. 15, кв. 6'),
(6, 'м. Харків, вул. Сумська, буд. 22, кв. 9'),
(7, 'м. Дніпро, пр. Дмитра Яворницького, буд. 45, кв. 2'),
(8, 'м. Київ, вул. Жилянська, буд. 120, кв. 33');

INSERT INTO TENANT (full_name, phone_number) VALUES
('Ковальчук Юрій Володимирович', '+380678889911'),
('Бондаренко Тетяна Олегівна', '+380509990022'),
('Ткаченко Сергій Анатолійович', '+380931110033'),
('Романенко Наталія Вікторівна', '+380632221144'),
('Олійник Артем Миколайович', '+380973332255'),
('Савченко Юлія Василівна', '+380504443366'),
('Мороз Павло Дмитрович', '+380675554477');

INSERT INTO REALTOR (full_name, phone_number, commission_rate) VALUES
('Захарченко Ігор Петрович', '+380673334455', 4.50),
('Кучер Вікторія Олександрівна', '+380504445566', 5.00),
('Левченко Олександр Михайлович', '+380935556677', 3.50),
('Павленко Світлана Іванівна', '+380636667788', 4.00),
('Демченко Максим Сергійович', '+380977778899', 4.50),
('Марченко Наталія Павлівна', '+380508889900', 5.00),
('Руденко Андрій Володимирович', '+380679990011', 3.75);

INSERT INTO APPLICATION (tenant_id, property_id, submission_date, status) VALUES
(4, 5, '2026-09-08', 'схвалено'),
(5, 6, '2026-09-10', 'в обробці'),
(6, 7, '2026-09-12', 'відхилено'),
(7, 8, '2026-09-15', 'схвалено'),
(8, 9, '2026-09-18', 'схвалено'),
(9, 10, '2026-09-20', 'в обробці');

INSERT INTO LEASE_AGREEMENT (property_id, tenant_id, realtor_id, start_date, end_date, rental_amount, agency_commission) VALUES
(3, 3, 3, '2026-10-10', '2027-10-09', 11000.00, 440.00),
(5, 4, 4, '2026-10-15', '2027-04-15', 20000.00, 900.00),
(6, 5, 5, '2026-10-20', '2027-10-19', 14000.00, 630.00),
(7, 6, 6, '2026-11-01', '2027-11-01', 16500.00, 825.00),
(8, 7, 7, '2026-11-05', '2027-05-05', 22000.00, 825.00),
(9, 8, 8, '2026-11-10', '2027-11-09', 13500.00, 675.00),
(10, 9, NULL, '2026-11-15', '2027-11-14', 19000.00, NULL); -- Договір укладено без ріелтора (комісія та ID ріелтора NULL)



-------------------------------------------------1 
SELECT p.property_id, p.adress, SUM(l.rental_amount) as total_rental_amount
FROM lease_agreement l
inner join property p on p.property_id = l.property_id
group by p.property_id, p.adress
HAVING SUM(l.rental_amount) > 10000;

-------------------------------------------------2

SELECT p.adress, count (o.*) as total_owners
FROM Property p
right JOIN  property_owner o on o.owner_id = p.owner_id
GROUP BY p.property_id, p.adress;

-------------------------------------------------3

SELECT 
	r.full_name AS realtor_name,
    t.full_name AS tenant_name,    
    COUNT(l.lease_id) AS total_leases
FROM tenant t
CROSS JOIN realtor r
LEFT JOIN lease_agreement l ON l.tenant_id = t.tenant_id AND l.realtor_id = r.realtor_id
GROUP BY t.tenant_id, t.full_name, r.realtor_id, r.full_name;
-------------------------------------------------4

SELECT lease_id, property_id, rental_amount
FROM lease_agreement
WHERE rental_amount > (SELECT AVG(rental_amount) FROM lease_agreement);

-------------------------------------------------5

SELECT property_id, adress
FROM property
WHERE owner_id IN (
    SELECT owner_id 
    FROM property_owner 
    WHERE full_name = 'Шевченко Тарас Григорович'
);