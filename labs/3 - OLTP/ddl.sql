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
