update lease_agreement
set start_date = now(), rental_amount = 10000
where lease_id = 2;
select * from lease_agreement

-------------------------------------------

insert into property (owner_id, adress)
values (2, 'м. малин, вул. Шевченка, буд. 21');
select * from Property

-------------------------------------------

delete from application 
where status = 'в обробці';
select * from application

INSERT INTO tenant (full_name, phone_number, email)
VALUES ('Мельник Дмитро Андрійович', '+380509876543', 'dmytro.melnyk@gmail.com');

SELECT * FROM tenant;

INSERT INTO lease_agreement (property_id, tenant_id, realtor_id, start_date, end_date, rental_amount, agency_commission)
VALUES (1, 1, 1, '2026-11-01', '2027-10-31', 16000.00, 800.00);

SELECT lease_id, property_id, rental_amount 
FROM lease_agreement 
WHERE rental_amount > 15000;

UPDATE lease_agreement
SET rental_amount = 17000.00
WHERE lease_id = 1;

SELECT * FROM lease_agreement WHERE lease_id = 1;