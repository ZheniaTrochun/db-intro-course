DROP TABLE IF EXISTS alert;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS air_target;
DROP TABLE IF EXISTS data_source;
DROP TABLE IF EXISTS user_account;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS oblast;


CREATE TABLE oblast (
    oblast_id  SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE city (
    city_id    SERIAL PRIMARY KEY,
    oblast_id  INTEGER       NOT NULL REFERENCES oblast(oblast_id),
    name       VARCHAR(100)  NOT NULL,
    latitude   NUMERIC(9,6)  NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
    longitude  NUMERIC(9,6)  NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    population INTEGER       CHECK (population >= 0),
    CONSTRAINT uq_city_name_oblast UNIQUE (name, oblast_id)
);

CREATE TABLE user_account (
    user_id          SERIAL PRIMARY KEY,
    full_name        VARCHAR(150) NOT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    telegram_chat_id VARCHAR(50),
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE data_source (
    source_id   SERIAL PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    source_kind VARCHAR(30)  NOT NULL
                CONSTRAINT ck_source_kind
                CHECK (source_kind IN ('radar', 'official_channel', 'monitoring_channel')),
    reliability INTEGER      NOT NULL DEFAULT 3
                CONSTRAINT ck_reliability CHECK (reliability BETWEEN 1 AND 5)
);

CREATE TABLE air_target (
    target_id    SERIAL PRIMARY KEY,
    source_id    INTEGER       NOT NULL REFERENCES data_source(source_id),
    target_type  VARCHAR(50)   NOT NULL,
    status       VARCHAR(20)   NOT NULL DEFAULT 'active'
                 CONSTRAINT ck_target_status
                 CHECK (status IN ('active', 'neutralized', 'left_territory', 'lost')),
    latitude     NUMERIC(9,6)  NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
    longitude    NUMERIC(9,6)  NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    speed_kmh    INTEGER       CHECK (speed_kmh >= 0),
    last_seen_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subscription (
    subscription_id  SERIAL PRIMARY KEY,
    user_id          INTEGER   NOT NULL REFERENCES user_account(user_id) ON DELETE CASCADE,
    city_id          INTEGER   NOT NULL REFERENCES city(city_id),
    radius_km        INTEGER   NOT NULL
                     CONSTRAINT ck_radius CHECK (radius_km BETWEEN 10 AND 300),
    min_threat_level INTEGER   NOT NULL DEFAULT 1
                     CONSTRAINT ck_min_threat CHECK (min_threat_level BETWEEN 1 AND 5),
    is_active        BOOLEAN   NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- пара "користувач + місто" не повторюється
    CONSTRAINT uq_subscription_user_city UNIQUE (user_id, city_id)
);

CREATE TABLE alert (
    alert_id        SERIAL PRIMARY KEY,
    subscription_id INTEGER       NOT NULL REFERENCES subscription(subscription_id) ON DELETE CASCADE,
    target_id       INTEGER       NOT NULL REFERENCES air_target(target_id),
    distance_km     NUMERIC(6,2)  NOT NULL
                    CONSTRAINT ck_alert_distance CHECK (distance_km >= 0 AND distance_km <= 300),
    threat_level    INTEGER       NOT NULL
                    CONSTRAINT ck_alert_threat CHECK (threat_level BETWEEN 1 AND 5),
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_status VARCHAR(20)   NOT NULL DEFAULT 'pending'
                    CONSTRAINT ck_delivery_status
                    CHECK (delivery_status IN ('pending', 'sent', 'failed'))
);


-- 2. INSERT


INSERT INTO oblast (name) VALUES
    ('Чернігівська'),
    ('Київська'),
    ('Харківська'),
    ('Львівська'),
    ('Одеська');

INSERT INTO city (oblast_id, name, latitude, longitude, population) VALUES
    (1, 'Чернігів', 51.498200, 31.289300,  285000),
    (2, 'Бровари',  50.511000, 30.790900,  100000),
    (3, 'Харків',   49.993500, 36.230400, 1400000),
    (4, 'Львів',    49.839700, 24.029700,  720000),
    (5, 'Одеса',    46.482500, 30.723300, 1000000);

INSERT INTO user_account (full_name, email, telegram_chat_id) VALUES
    ('Олександр Гнатовський',  'oleksandr@example.com', '100000001'),
    ('Марія Коваленко',  'maria@example.com',     '100000002'),
    ('Іван Петренко',    'ivan@example.com',      NULL),
    ('Олена Шевченко',   'olena@example.com',     '100000004'),
    ('Андрій Бондаренко','andrii@example.com',    '100000005');

INSERT INTO data_source (name, source_kind, reliability) VALUES
    ('Офіційний канал Повітряних сил', 'official_channel',   5),
    ('Радіолокаційна станція Північ',  'radar',              5),
    ('Моніторинговий канал А',         'monitoring_channel', 3),
    ('Радіолокаційна станція Південь', 'radar',              4),
    ('Моніторинговий канал Б',         'monitoring_channel', 2);

INSERT INTO air_target (source_id, target_type, status, latitude, longitude, speed_kmh, last_seen_at) VALUES
    (1, 'drone',             'active',         51.200000, 31.100000, 150, '2026-11-07 03:10:00'),
    (2, 'cruise_missile',    'active',         50.300000, 30.900000, 800, '2026-11-07 03:12:00'),
    (3, 'drone',             'neutralized',    49.700000, 36.400000,   0, '2026-11-07 02:40:00'),
    (1, 'ballistic_missile', 'left_territory', 52.500000, 24.000000, 900, '2026-11-07 01:55:00'),
    (4, 'drone',             'lost',           46.900000, 31.000000, 140, '2026-11-07 02:20:00');

INSERT INTO subscription (user_id, city_id, radius_km, min_threat_level, is_active) VALUES
    (1, 1, 100, 2, TRUE),   -- Олександр Чернігів
    (1, 3, 150, 3, TRUE),   -- Олександр Харків
    (2, 2,  80, 1, TRUE),   -- Марія Бровари
    (3, 4, 200, 3, FALSE),  -- Іван Львів
    (4, 5, 120, 2, TRUE),   -- Олена Одеса
    (5, 1,  60, 1, TRUE);   -- Андрій Чернігів

INSERT INTO alert (subscription_id, target_id, distance_km, threat_level, created_at, delivery_status) VALUES
    (1, 1, 35.60, 3, '2026-11-07 03:11:00', 'sent'),
    (6, 1, 35.60, 3, '2026-11-07 03:11:00', 'sent'),
    (3, 2, 24.60, 4, '2026-11-07 03:13:00', 'failed'),
    (2, 3, 34.80, 4, '2026-11-07 02:35:00', 'sent'),
    (5, 5, 51.00, 3, '2026-11-07 02:18:00', 'pending');


-- 3. Перевірка даних


SELECT * FROM oblast;
SELECT * FROM city;
SELECT * FROM user_account;
SELECT * FROM data_source;
SELECT * FROM air_target;
SELECT * FROM subscription;
SELECT * FROM alert;

-- Перевірка зв'язків через JOIN: хто і про що отримав сповіщення
SELECT u.full_name, c.name AS city, t.target_type, a.distance_km, a.threat_level, a.delivery_status
FROM alert a
JOIN subscription s  ON s.subscription_id = a.subscription_id
JOIN user_account u  ON u.user_id = s.user_id
JOIN city c          ON c.city_id = s.city_id
JOIN air_target t    ON t.target_id = a.target_id;