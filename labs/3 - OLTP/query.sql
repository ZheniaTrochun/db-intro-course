-- Видалення користувача
delete from "user" where user_id=4;

-- Вибір відгуків користувача з user_id = 1;
select * from review where user_id = 1 

-- Зміна даних видавця
select * from publisher where publisher_id = 1 
update publisher
set publisher_name = 'Neuvas Studios',
	website = 'https://neuvas.com',
	support_email = 'support@neuvas.com'
where publisher_name = 'Novas Studios';
select * from publisher where publisher_id = 1;

-- Додавання нового цифровога продукту
select * from app where publisher_id = 1;
insert into app (publisher_id, parent_game_id, title, app_type, description, price, release_date)
values
    (1, 1, 'Shadows of Buntwelt: Islands of Mist', 'dlc', 'Major expansion unraveling a new story.', 19.99, '2026-10-04');

select * from app

-- Покупка продукту користувачем
select * from user_library where user_id = 1;
insert into "order" (user_id, receiver_id, total_amount, payment_method, status, order_date)
values
    (1, 1, 19.99, 'credit card', 'completed', '2026-10-05 23:27:00+01');
insert into order_item (order_id, app_id, price_at_purchase)
values
    (5, 5, 19.99);
insert into user_library (user_id, app_id, added_date)
values
    (1, 5, '2026-10-05 23:28:00+01');
select * from user_library where user_id = 1;
select * from "order" where user_id = 1;
select * from order_item where order_id = 5;

-- Користувач залишає відгук
update user_library set playtime_hours=1 where user_id=1 and app_id=5;
select * from user_library where user_id=1
insert into review (user_id, app_id, is_recommended, playtime_at_review, content, created_at)
values
    (1, 5, false, 1, 'Such a let down. It trues does not go worse than that.', '2026-10-06 11:07:00+01');
update user_library set playtime_hours=2 where user_id=1 and app_id=5;
insert into review (user_id, app_id, is_recommended, playtime_at_review, content, created_at)
values
    (1, 5, false, 2, 'Such a let down. It trues does not go worse than that.', '2026-10-06 14:51:00+01');
select * from review where NOT is_recommended;