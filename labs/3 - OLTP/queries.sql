select * from users;

--- користувачі старше 30 років
select 
	user_id,
	concat(first_name, ' ', last_name) as full_name,
	email,
	date_of_birth
from users
where date_of_birth < now() - INTERVAL '30 years';

select * from player;

--- гравці зі званням ЗМС, відсортовані за рейтингом
select 
	p.player_id,
	u.first_name,
	u.last_name,
	p.rating,
	p.sports_title
from player p
join users u on p.person_id = u.user_id
where sports_title = 'HONORED_MASTER_OF_SPORTS'
	and rating is not null
order by rating desc;

select * from match_participant;

--- winner of the final match_id = 3
select 
	mp.match_participant_id,
	u.first_name,
	u.last_name,
	mp.match_id,
	mp.player_id,
	mp.team_id,
	mp.frames_won,
	mp.points,
	mp.side,
	mp.is_winner
from match_participant mp
join player p on mp.player_id = p.player_id
join users u on p.person_id = u.user_id
where match_id = 3
	and is_winner = true;

select * from tournament_registration;
select * from tournament;

--- number of registrations for tournament id = 1 with status paid
select count(*)
from tournament_registration
where tournament_id = 1
	and payment_status = 'PAID';

select * from users;

--- new user
insert into users (first_name, last_name, email, password_hash, date_of_birth)
values (
	'Діана',
	'Міронова',
	'mironova@example.com',
	'$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe',
	'1996-05-09'
)
returning user_id, first_name, last_name, email, date_of_birth;

select * from player;

--- оформлення картки гравця ЗМС для нового користувача
insert into player (person_id, rating, sports_title)
values (
	(select user_id from users where email = 'mironova@example.com'),
	2450,
	'HONORED_MASTER_OF_SPORTS'
)
returning player_id, person_id, rating, sports_title;

select * from tournament_registration;

--- реєстрація гравця на відкритий турнір id = 2
insert into tournament_registration (tournament_id, player_id, team_id, payment_status, prize_won)
values (
	2,
	(select p.player_id from player p join users u on p.person_id = u.user_id where u.email = 'mironova@example.com'),
	null,
	'PENDING',
	0.00
)
returning tournament_registration_id, tournament_id, player_id, payment_status;

--- підтвердження оплати участі у турнірі (переведення статусу з PENDING на PAID)
update tournament_registration
set payment_status = 'PAID'
where tournament_id = 2
	and player_id = (select p.player_id from player p join users u on p.person_id = u.user_id where u.email = 'mironova@example.com')
returning tournament_registration_id, tournament_id, player_id, payment_status;

select * from billiard_table;

--- оперативне призначення столу на матч (зміна статусу столу на OCCUPIED)
update billiard_table
set table_status = 'OCCUPIED'
where table_id = 1
returning table_id, table_number, table_status;

select * from player;

--- нарахування рейтингових очок переможцю фіналу (+30 очок Білозерову)
update player
set rating = rating + 30
where player_id = 1
returning player_id, rating;

select * from tournament_registration;

--- скасування неоплаченої реєстрації гравця Паламаря на турнір id = 2
delete from tournament_registration
where tournament_id = 2
	and player_id = 2
	and payment_status = 'PENDING'
returning tournament_registration_id, tournament_id, player_id, payment_status;

select * from users;

--- створення тимчасового користувача для видалення
insert into users (first_name, last_name, email, password_hash, date_of_birth)
values (
	'Тест',
	'Тестовий',
	'test_delete@example.com',
	'$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe',
	'2000-01-01'
)
returning user_id, first_name, last_name, email;

--- видалення користувача за email
delete from users
where email = 'test_delete@example.com'
returning user_id, first_name, last_name, email;
