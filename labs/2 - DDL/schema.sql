CREATE TYPE court_surface AS ENUM ('Hard', 'Clay', 'Grass', 'Carpet');
CREATE TYPE tournament_category AS ENUM ('Grand Slam', 'WTA 1000', 'WTA 500', 'WTA 250', 'WTA Finals');
CREATE TYPE plays_hand_type AS ENUM ('Right', 'Left', 'Ambidextrous');
CREATE TYPE back_hand_type AS ENUM ('One-handed', 'Two-handed');
CREATE TYPE career_status_type AS ENUM ('Active', 'Retired');
CREATE TYPE match_round AS ENUM ('R128', 'R64', 'R32', 'R16', 'Quarterfinal', 'Semifinal', 'Final');
CREATE TYPE match_status AS ENUM ('Scheduled', 'Live', 'Finished', 'Retired', 'Walkover');


CREATE TABLE Users (
    user_id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
 
CREATE TABLE Tournaments (
    tournament_id UUID PRIMARY KEY,
    tournament_name VARCHAR(150) NOT NULL,
    category tournament_category NOT NULL,
    surface court_surface NOT NULL,
    country_code CHAR(3) NOT NULL,
    city VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    year INT NOT NULL,
    CONSTRAINT tournament_dates_check CHECK (end_date >= start_date),
    CONSTRAINT tournament_year_check CHECK (year = EXTRACT(YEAR FROM start_date)),
    CONSTRAINT unique_tournament_name_year UNIQUE (tournament_name, year)
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
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country_code CHAR(3) NOT NULL
);
 
CREATE TABLE PlayerRankingHistory (
    ranking_id UUID PRIMARY KEY,
    player_id UUID NOT NULL REFERENCES Players(player_id) ON DELETE CASCADE,
    rank INT NOT NULL CHECK (rank >= 1),
    points INT NOT NULL CHECK (points >= 0),
    ranking_date DATE NOT NULL,
    CONSTRAINT unique_player_data_rank UNIQUE (player_id, ranking_date)
);
 
CREATE TABLE PlayerTitles (
    title_id UUID PRIMARY KEY,
    player_id UUID NOT NULL REFERENCES Players(player_id) ON DELETE CASCADE,
    tournament_id UUID NOT NULL REFERENCES Tournaments(tournament_id) ON DELETE CASCADE,
    CONSTRAINT unique_player_title UNIQUE (player_id, tournament_id),
    CONSTRAINT unique_tournament_champion UNIQUE (tournament_id)
);
 
CREATE TABLE Courts (
    court_id UUID PRIMARY KEY,
    tournament_id UUID REFERENCES Tournaments(tournament_id) ON DELETE SET NULL,
    court_name VARCHAR(100) NOT NULL
);
 
CREATE TABLE Matches (
    match_id UUID PRIMARY KEY,
    tournament_id UUID NOT NULL REFERENCES Tournaments(tournament_id) ON DELETE CASCADE,
    player1_id UUID NOT NULL REFERENCES Players(player_id) ON DELETE CASCADE,
    player2_id UUID NOT NULL REFERENCES Players(player_id) ON DELETE CASCADE,
    winner_id UUID REFERENCES Players(player_id) ON DELETE SET NULL,
    round match_round NOT NULL,
    status match_status NOT NULL DEFAULT 'Scheduled',
    match_date TIMESTAMP WITH TIME ZONE,
    duration_minutes INT,
    court_id UUID REFERENCES Courts(court_id) ON DELETE SET NULL,
    CONSTRAINT different_players_check CHECK (player1_id <> player2_id),
    CONSTRAINT valid_winner_check CHECK (winner_id IS NULL OR winner_id IN (player1_id, player2_id)),
    CONSTRAINT check_winner_if_finished CHECK (status <> 'Finished' OR winner_id IS NOT NULL)
);
 
CREATE TABLE MatchSets (
    set_id UUID PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES Matches(match_id) ON DELETE CASCADE,
    set_number INT NOT NULL,
    player1_games INT NOT NULL CHECK (player1_games BETWEEN 0 AND 7),
    player2_games INT NOT NULL CHECK (player2_games BETWEEN 0 AND 7),
    player1_tiebreak INT CHECK (player1_tiebreak IS NULL OR player1_tiebreak >= 0),
    player2_tiebreak INT CHECK (player2_tiebreak IS NULL OR player2_tiebreak >= 0),
    CONSTRAINT set_number_range CHECK (set_number BETWEEN 1 AND 3),
    CONSTRAINT unique_match_set UNIQUE (match_id, set_number)
);
 
CREATE TABLE PlayerMatchStatistics (
    stat_id UUID PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES Matches(match_id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES Players(player_id) ON DELETE CASCADE,
    aces INT DEFAULT 0 CHECK (aces >= 0),
    double_faults INT DEFAULT 0 CHECK (double_faults >= 0),
    first_serves_in INT DEFAULT 0 CHECK (first_serves_in >= 0),
    first_serve_points_won INT DEFAULT 0 CHECK (first_serve_points_won >= 0),
    first_serves_total INT DEFAULT 0 CHECK (first_serves_total >= 0),
    second_serve_points_won INT DEFAULT 0 CHECK (second_serve_points_won >= 0),
    second_serve_points_total INT DEFAULT 0 CHECK (second_serve_points_total >= 0),
    break_points_converted INT DEFAULT 0 CHECK (break_points_converted >= 0),
    break_points_saved INT DEFAULT 0 CHECK (break_points_saved >= 0),
    break_points_opportunities INT DEFAULT 0 CHECK (break_points_opportunities >= 0),
    break_points_faced INT DEFAULT 0 CHECK (break_points_faced >= 0),
    total_points_won INT DEFAULT 0 CHECK (total_points_won >= 0),
    CONSTRAINT unique_player_match_stat UNIQUE (match_id, player_id)
);

INSERT INTO Users (user_id, username, email, password_hash) VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin_anna', 'anna.admin@tennis.com', 'hash_pass_123'),
    ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'tennis_fan_99', 'fan99@gmail.com', 'hash_pass_456'),
    ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'sport_journalist', 'news@ukr.net', 'hash_pass_789');

INSERT INTO Tournaments (tournament_id, tournament_name, category, surface, country_code, city, start_date, end_date, year) VALUES
    ('a1111111-1111-1111-1111-111111111111', 'Australian Open', 'Grand Slam', 'Hard', 'AUS', 'Melbourne', '2026-01-12', '2026-01-25', 2026),
    ('a2222222-2222-2222-2222-222222222222', 'BNP Paribas Open', 'WTA 1000', 'Hard', 'USA', 'Indian Wells', '2026-03-04', '2026-03-15', 2026),
    ('a3333333-3333-3333-3333-333333333333', 'Wimbledon', 'Grand Slam', 'Grass', 'GBR', 'London', '2026-06-29', '2026-07-12', 2026),
    ('a4444444-4444-4444-4444-444444444444', 'Roland Garros', 'Grand Slam', 'Clay', 'FRA', 'Paris', '2026-05-25', '2026-06-07', 2026);

INSERT INTO Players (player_id, first_name, last_name, country_code, date_of_birth, birth_place, height_cm, plays_hand, back_hand, photo_url, turning_pro_year, career_status) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Elina', 'Svitolina', 'UKR', '1994-09-12', 'Odesa', 174, 'Right', 'Two-handed', 'https://example.com/svitolina.jpg', 2008, 'Active'),
    ('22222222-2222-2222-2222-222222222222', 'Marta', 'Kostyuk', 'UKR', '2002-06-28', 'Kyiv', 175, 'Right', 'Two-handed', 'https://example.com/kostyuk.jpg', 2018, 'Active'),
    ('33333333-3333-3333-3333-333333333333', 'Coco', 'Gauff', 'USA', '2004-03-13', 'Delray Beach', 175, 'Right', 'Two-handed', 'https://example.com/gauff.jpg', 2018, 'Active');

INSERT INTO PlayerRankingHistory (ranking_id, player_id, rank, points, ranking_date) VALUES
    ('f1eebc99-9c0b-4ef8-bb6d-6bb9bd380001', '11111111-1111-1111-1111-111111111111', 6, 5229, '2026-10-29'), 
    ('f2eebc99-9c0b-4ef8-bb6d-6bb9bd380002', '22222222-2222-2222-2222-222222222222', 10, 3920, '2026-10-29'), 
    ('f3eebc99-9c0b-4ef8-bb6d-6bb9bd380003', '33333333-3333-3333-3333-333333333333', 5, 5973, '2026-10-29');

INSERT INTO Coaches (coach_id, player_id, first_name, last_name, country_code) VALUES
    ('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', '11111111-1111-1111-1111-111111111111', 'Andrew', 'Bettles', 'GBR'),
    ('e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', '22222222-2222-2222-2222-222222222222', 'Sandra', 'Zaniewska', 'POL'),
    ('f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a66', '33333333-3333-3333-3333-333333333333', 'Jean-Christophe', 'Faurel', 'FRA');

INSERT INTO PlayerTitles (title_id, player_id, tournament_id) VALUES 
    ('b1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 
     '11111111-1111-1111-1111-111111111111',
     'a4444444-4444-4444-4444-444444444444'),
    ('b2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', 
     '33333333-3333-3333-3333-333333333333',
     'a1111111-1111-1111-1111-111111111111'),
    ('b3eeec99-9c0b-4ef8-bb6d-6bb9bd380a33', 
     '22222222-2222-2222-2222-222222222222',
     'a2222222-2222-2222-2222-222222222222');
   
INSERT INTO Courts (court_id, tournament_id, court_name) VALUES
    ('c1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a4444444-4444-4444-4444-444444444444', 'Center Court'),
    ('c2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', 'a4444444-4444-4444-4444-444444444444', 'Court 1'),
    ('c3eeec99-9c0b-4ef8-bb6d-6bb9bd380a33', 'a4444444-4444-4444-4444-444444444444', 'Court 2'),
    ('c4eeec99-9c0b-4ef8-bb6d-6bb9bd380a44', 'a1111111-1111-1111-1111-111111111111', 'Rod Laver Arena'),
    ('c5eeec99-9c0b-4ef8-bb6d-6bb9bd380a55', 'a2222222-2222-2222-2222-222222222222', 'Stadium 1');

INSERT INTO Matches (match_id, tournament_id, player1_id, player2_id, winner_id, round, status, match_date, duration_minutes, court_id) VALUES 
    ('e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 
     'a4444444-4444-4444-4444-444444444444', 
     '11111111-1111-1111-1111-111111111111',
     '22222222-2222-2222-2222-222222222222',
     '11111111-1111-1111-1111-111111111111',
     'Final', 'Finished', '2026-06-01 14:00:00+00', 125, 'c1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11'),
    ('e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', 
     'a1111111-1111-1111-1111-111111111111', 
     '33333333-3333-3333-3333-333333333333',
     '11111111-1111-1111-1111-111111111111',
     '33333333-3333-3333-3333-333333333333',
     'Final', 'Finished', '2026-01-24 09:30:00+00', 148, 'c4eeec99-9c0b-4ef8-bb6d-6bb9bd380a44'),
    ('e3eeec99-9c0b-4ef8-bb6d-6bb9bd380a33', 
     'a2222222-2222-2222-2222-222222222222', 
     '22222222-2222-2222-2222-222222222222',
     '33333333-3333-3333-3333-333333333333',
     '22222222-2222-2222-2222-222222222222',
     'Final', 'Finished', '2026-03-15 21:00:00+00', 131, 'c5eeec99-9c0b-4ef8-bb6d-6bb9bd380a55');

INSERT INTO MatchSets (set_id, match_id, set_number, player1_games, player2_games, player1_tiebreak, player2_tiebreak) VALUES
    ('d1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 1, 6, 4, NULL, NULL),
    ('d2eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 2, 3, 6, NULL, NULL),
    ('d3eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 3, 6, 2, NULL, NULL),
    ('d4eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', 1, 6, 4, NULL, NULL),
    ('d5eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', 2, 3, 6, NULL, NULL),
    ('d6eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', 3, 7, 6, 7, 5),
    ('d7eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e3eeec99-9c0b-4ef8-bb6d-6bb9bd380a33', 1, 7, 6, 7, 4),
    ('d8eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e3eeec99-9c0b-4ef8-bb6d-6bb9bd380a33', 2, 6, 3, NULL, NULL);

INSERT INTO PlayerMatchStatistics (stat_id, match_id, player_id, aces, double_faults, total_points_won) VALUES 
    ('a5eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', '11111111-1111-1111-1111-111111111111', 5, 2, 98),
    ('a6eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e1eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', '22222222-2222-2222-2222-222222222222', 3, 4, 85),
    ('a7eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', '33333333-3333-3333-3333-333333333333', 7, 5, 106),
    ('a8eeec99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e2eeec99-9c0b-4ef8-bb6d-6bb9bd380a22', '11111111-1111-1111-1111-111111111111', 3, 2, 92);