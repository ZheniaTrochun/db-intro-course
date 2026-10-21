---------------------------------------------------------------------1

update lease_agreement
set start_date = now(), rental_amount = 10000
where lease_id = 2;
select * from lease_agreement

---------------------------------------------------------------------2

insert into property (owner_id, adress)
values (2, 'м. малин, вул. Шевченка, буд. 21');
select * from Property

---------------------------------------------------------------------3

delete from application 
where status = 'в обробці';
select * from application

---------------------------------------------------------------------4

INSERT INTO tenant (full_name, phone_number)
VALUES ('Мельник Дмитро Андрійович', '+380509876543');
SELECT * FROM tenant;

---------------------------------------------------------------------5

INSERT INTO lease_agreement (property_id, tenant_id, realtor_id, start_date, end_date, rental_amount, agency_commission)
VALUES (1, 1, 1, '2026-11-01', '2027-10-31', 16000.00, 800.00);
SELECT * FROM lease_agreement;

---------------------------------------------------------------------6

SELECT lease_id, property_id, rental_amount 
FROM lease_agreement 
WHERE rental_amount > 15000;

---------------------------------------------------------------------7

UPDATE lease_agreement
SET rental_amount = 17000.00
WHERE lease_id = 1;

SELECT * FROM lease_agreement WHERE lease_id = 1;