CREATE TYPE court_surface AS ENUM ('Hard', 'Clay', 'Grass', 'Carpet');
CREATE TYPE tournament_category AS ENUM ('Grand Slam', 'WTA 1000', 'WTA 500', 'WTA 250', 'WTA Finals');
CREATE TYPE plays_hand_type AS ENUM ('Right', 'Left', 'Ambidextrous');
CREATE TYPE back_hand_type AS ENUM ('One-handed', 'Two-handed');
CREATE TYPE career_status_type AS ENUM ('Active', 'Retired');


CREATE TABLE Users (
    user_id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR (150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Tournaments (
    tournament_id UUID PRIMARY KEY,
    tournament_name VARCHAR(150),
    category tournament_category NOT NULL,
    surface court_surface NOT NULL,
    country_code CHAR(3) NOT NULL,
    city VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    year INT NOT NULL
);

CREATE TABLE Players (
    player_id UUID PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country_code CHAR(3) NOT NULL,
    date_of_birth DATE NOT NULL,
    birth_place VARCHAR(100) NOT NULL,
    height_cm INT,
    plays_hand plays_hand_type NOT NULL,
    back_hand back_hand_type NOT NULL,
    photo_url TEXT,
    turning_pro_year INT,
    career_status career_status_type NOT NULL
);

CREATE TABLE Coaches (
    coach_id UUID PRIMARY KEY,
    player_id UUID REFERENCES Players(player_id) ON DELETE SET NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    country_code CHAR(3)
);

CREATE TABLE PlayerRankingHistory (
    ranking_id UUID PRIMARY KEY,
    player_id UUID REFERENCES Players(player_id) ON DELETE CASCADE,
    rank INT NOT NULL,
    points INT NOT NULL,
    ranking_date DATE NOT NULL,
    CONSTRAINT unique_player_data_rank UNIQUE (player_id, ranking_date)
);

CREATE TABLE PlayerTitles (
    title_id UUID PRIMARY KEY,
    player_id UUID REFERENCES Players(player_id) ON DELETE CASCADE,
    tournament_id UUID, --треба додати потім посиланя
    CONSTRAINT unique_player_title UNIQUE (player_id, tournament_id)
);

INSERT INTO Users (user_id, username, email, password_hash) VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin_anna', 'anna.admin@tennis.com', 'hash_pass_123'),
    ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'tennis_fan_99', 'fan99@gmail.com', 'hash_pass_456'),
    ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'sport_journalist', 'news@ukr.net', 'hash_pass_789');

INSERT INTO Players (player_id, first_name, last_name, country_code, date_of_birth, birth_place, height_cm, plays_hand, back_hand, photo_url, turning_pro_year, career_status) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Elina', 'Svitolina', 'UKR', '1994-09-12', 'Odesa', 174, 'Right', 'Two-handed', 'https://example.com/svitolina.jpg', 2008, 'Active'),
    ('22222222-2222-2222-2222-222222222222', 'Marta', 'Kostyuk', 'UKR', '2002-06-28', 'Kyiv', 175, 'Right', 'Two-handed', 'https://example.com/kostyuk.jpg', 2018, 'Active'),
    ('33333333-3333-3333-3333-333333333333', 'Coco', 'Gauff', 'USA', '2004-03-13', 'Delray Beach', 175, 'Right', 'Two-handed', 'https://example.com/gauff.jpg', 2018, 'Active');

INSERT INTO PlayerRankingHistory (ranking_id, player_id, rank, points, ranking_date) VALUES
    ('r1eebc99-9c0b-4ef8-bb6d-6bb9bd380001', '11111111-1111-1111-1111-111111111111', 6, 5229, '2026-10-29'), 
    ('r2eebc99-9c0b-4ef8-bb6d-6bb9bd380002', '22222222-2222-2222-2222-222222222222', 10, 3920, '2026-10-29'), 
    ('r3eebc99-9c0b-4ef8-bb6d-6bb9bd380003', '33333333-3333-3333-3333-333333333333', 5, 5973, '2026-10-29');

INSERT INTO Coaches (coach_id, player_id, first_name, last_name, country_code) VALUES
    ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', '11111111-1111-1111-1111-111111111111', 'Andrew', 'Bettles', 'GBR'),
    ('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', '22222222-2222-2222-2222-222222222222', 'Sandra', 'Zaniewska', 'POL'),
    ('f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a66', '33333333-3333-3333-3333-333333333333', 'Jean-Christophe', 'Faurel', 'FRA');