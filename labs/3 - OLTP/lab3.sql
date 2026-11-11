-- 1. SELECT


-- 1.1 Міста понад 500к людей
SELECT name, population
FROM city
WHERE population > 500000
ORDER BY population DESC;

-- 1.2 Активні повітряні цілі
SELECT target_id, target_type, speed_kmh, last_seen_at
FROM air_target
WHERE status = 'active';


-- 2. INSERT


-- 2.1 Нова область
INSERT INTO oblast (name)
VALUES ('Сумська');

SELECT * FROM oblast WHERE name = 'Сумська';


-- 2.2 Новий користувач (created_at та telegram_chat_id за замовчуванням)
INSERT INTO user_account (full_name, email)
VALUES ('Тетяна Мельник', 'tetiana@example.com');

SELECT user_id, full_name, email, telegram_chat_id, created_at
FROM user_account
WHERE email = 'tetiana@example.com';


-- 3. UPDATE


-- 3.1 Ціль 2 збито, змінюємо статус і швидкість
SELECT target_id, target_type, status, speed_kmh
FROM air_target WHERE target_id = 2;

UPDATE air_target
SET status = 'neutralized', speed_kmh = 0
WHERE target_id = 2;

-- 3.2 Іван знову активував підписку на Львів і збільшив радіус
SELECT subscription_id, radius_km, is_active
FROM subscription WHERE subscription_id = 4;

UPDATE subscription
SET is_active = TRUE, radius_km = 250
WHERE subscription_id = 4;


-- 4. DELETE


-- 4.1 Видалення запису сповіщення 5
SELECT * FROM alert WHERE alert_id = 5;

DELETE FROM alert
WHERE alert_id = 5;

-- 4.2 Видалення з користувача Андрій з його підписками та алертами.
SELECT 'subscription' AS table1, COUNT(*) FROM subscription WHERE user_id = 5
UNION ALL
SELECT 'alert', COUNT(*) FROM alert
WHERE subscription_id IN (SELECT subscription_id FROM subscription WHERE user_id = 5);

DELETE FROM user_account
WHERE email = 'andrii@example.com';

SELECT 'user_account' AS table1, COUNT(*) FROM user_account WHERE email = 'andrii@example.com'
UNION ALL
SELECT 'subscription', COUNT(*) FROM subscription WHERE user_id = 5
UNION ALL
SELECT 'alert (сповіщення 2)', COUNT(*) FROM alert WHERE alert_id = 2;
