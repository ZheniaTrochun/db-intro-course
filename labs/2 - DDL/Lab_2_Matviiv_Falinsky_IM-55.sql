-- Очищення таблиць перед повторним запуском (у зворотному порядку залежностей)
DROP TABLE IF EXISTS Match_Player CASCADE;
DROP TABLE IF EXISTS Player_Inventory CASCADE;
DROP TABLE IF EXISTS Match CASCADE;
DROP TABLE IF EXISTS Player CASCADE;
DROP TABLE IF EXISTS Item CASCADE;
DROP TABLE IF EXISTS Server CASCADE;

-- ============================================================================
-- 1. СТВОРЕННЯ ТАБЛИЦЬ (DDL)
-- ============================================================================

-- 1.1. Таблиця ігрових серверів (батьківська сутність)
CREATE TABLE Server (
    server_id    SERIAL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL UNIQUE,
    region       VARCHAR(50)  NOT NULL,
    max_capacity INTEGER      NOT NULL CHECK (max_capacity > 0)
);

-- 1.2. Таблиця гравців (залежить від Server)
CREATE TABLE Player (
    player_id  SERIAL PRIMARY KEY,
    server_id  INTEGER      NOT NULL,
    nickname   VARCHAR(32)  NOT NULL UNIQUE,
    email      VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    level      INTEGER      NOT NULL DEFAULT 1 CHECK (level > 0),
    rating     INTEGER      NOT NULL DEFAULT 1000 CHECK (rating >= 0),
    CONSTRAINT fk_player_server
        FOREIGN KEY (server_id) REFERENCES Server(server_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.3. Каталог внутрішньоігрових предметів (батьківська сутність)
CREATE TABLE Item (
    item_id         SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL UNIQUE,
    category        VARCHAR(50)  NOT NULL CHECK (category IN ('Character', 'Ship', 'Resource')),
    characteristics TEXT
);

-- 1.4. Інвентар гравців (асоціативна таблиця M:N між Player та Item)
CREATE TABLE Player_Inventory (
    player_id     INTEGER NOT NULL,
    item_id       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    item_level    INTEGER CHECK (item_level IS NULL OR item_level >= 0),
    acquired_date DATE    NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_player_inventory
        PRIMARY KEY (player_id, item_id),
    CONSTRAINT fk_inventory_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inventory_item
        FOREIGN KEY (item_id) REFERENCES Item(item_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.5. Таблиця проведених матчів (залежить від Server)
CREATE TABLE Match (
    match_id   SERIAL PRIMARY KEY,
    server_id  INTEGER   NOT NULL,
    match_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duration   INTEGER   NOT NULL CHECK (duration > 0),
    CONSTRAINT fk_match_server
        FOREIGN KEY (server_id) REFERENCES Server(server_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.6. Статистика участі гравців у матчах (асоціативна таблиця M:N між Match та Player)
CREATE TABLE Match_Player (
    match_id         INTEGER     NOT NULL,
    player_id        INTEGER     NOT NULL,
    result           VARCHAR(20) NOT NULL CHECK (result IN ('Victory', 'Defeat', 'Draw')),
    score            INTEGER     NOT NULL DEFAULT 0 CHECK (score >= 0),
    resources_earned INTEGER     NOT NULL DEFAULT 0 CHECK (resources_earned >= 0),
    kills            INTEGER     NOT NULL DEFAULT 0 CHECK (kills >= 0),
    deaths           INTEGER     NOT NULL DEFAULT 0 CHECK (deaths >= 0),
    CONSTRAINT pk_match_player
        PRIMARY KEY (match_id, player_id),
    CONSTRAINT fk_mp_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_mp_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================================
-- 2. ЗАПОВНЕННЯ ТЕСТОВИМИ ДАНИМИ (DML: INSERT INTO)
-- ============================================================================

-- 2.1. Додавання серверів (5 рядків)
INSERT INTO Server (server_id, name, region, max_capacity) VALUES
    (1, 'EU-Central-1', 'Europe',        15000),
    (2, 'EU-West-2',    'Europe',        12000),
    (3, 'NA-East-1',    'North America', 10000),
    (4, 'ASIA-Tokyo-1', 'Asia',          20000),
    (5, 'UA-Kyiv-Test', 'Europe',         5000);

-- 2.2. Додавання гравців (5 рядків)
INSERT INTO Player (player_id, server_id, nickname, email, created_at, level, rating) VALUES
    (1, 1, 'Rostislav77', 'rostyslav@example.com', '2026-09-01 14:20:00', 25, 1850),
    (2, 1, 'DianaStar',   'diana@example.com',     '2026-09-02 18:10:00', 22, 1720),
    (3, 2, 'AlexVanguard','alex.v@example.com',    '2026-09-10 11:05:00', 15, 1410),
    (4, 3, 'NightHunter', 'hunter@example.com',    '2026-09-15 21:45:00', 30, 2100),
    (5, 1, 'CyberPartner','partner@example.com',   '2026-09-20 09:30:00', 18, 1560);

-- 2.3. Додавання предметів у каталог (5 рядків)
INSERT INTO Item (item_id, name, category, characteristics) VALUES
    (1, 'Napoli',       'Ship',      'Heavy Cruiser, Caliber: 254mm, Speed: 35.5 knots, Exhaust Smoke Generator'),
    (2, 'Schlieffen',   'Ship',      'Battleship, Caliber: 420mm, Secondary Battery Range: 12.5km, Torpedoes'),
    (3, 'Conde',        'Ship',      'Super Cruiser, Caliber: 240mm, Burst Fire Mode, Speed: 35 knots'),
    (4, 'Commander_X',  'Character', 'Special Fleet Commander, +10% Reload Speed, +5% Survivability'),
    (5, 'Steel_Ingot',  'Resource',  'Rare crafting and upgrade currency earned in ranked matches');

-- 2.4. Додавання майна в інвентар гравців (6 рядків)
INSERT INTO Player_Inventory (player_id, item_id, quantity, item_level, acquired_date) VALUES
    (1, 1,   1,   10, '2026-09-05'),
    (1, 5, 450, NULL, '2026-09-06'),
    (2, 3,   1,   10, '2026-09-08'),
    (2, 4,   1,   21, '2026-09-09'),
    (3, 2,   1,   10, '2026-09-12'),
    (4, 5, 800, NULL, '2026-09-18');

-- 2.5. Додавання матчів (5 рядків)
INSERT INTO Match (match_id, server_id, match_date, duration) VALUES
    (1, 1, '2026-10-01 19:00:00',  920),
    (2, 1, '2026-10-01 19:30:00', 1050),
    (3, 2, '2026-10-02 20:15:00',  840),
    (4, 1, '2026-10-03 21:00:00', 1180),
    (5, 3, '2026-10-04 22:10:00',  760);

-- 2.6. Додавання результатів участі гравців у матчах (6 рядків)
INSERT INTO Match_Player (match_id, player_id, result, score, resources_earned, kills, deaths) VALUES
    (1, 1, 'Victory', 2450, 120, 4, 0),
    (1, 2, 'Victory', 2180, 110, 3, 0),
    (1, 3, 'Defeat',  1340,  50, 1, 1),
    (2, 1, 'Victory', 2690, 150, 5, 0),
    (3, 4, 'Victory', 2810, 160, 4, 0),
    (4, 5, 'Draw',    1600,  80, 2, 1);

-- Оновлення лічильників SERIAL після явної вставки ID
SELECT setval('server_server_id_seq', (SELECT MAX(server_id) FROM Server));
SELECT setval('player_player_id_seq', (SELECT MAX(player_id) FROM Player));
SELECT setval('item_item_id_seq',     (SELECT MAX(item_id) FROM Item));
SELECT setval('match_match_id_seq',   (SELECT MAX(match_id) FROM Match));

-- ============================================================================
-- 3. ПЕРЕВІРКА ЗАВАНТАЖЕНИХ ДАНИХ (SELECT)
-- ============================================================================
SELECT * FROM Server;
SELECT * FROM Player;
SELECT * FROM Item;
SELECT * FROM Player_Inventory;
SELECT * FROM Match;
SELECT * FROM Match_Player;