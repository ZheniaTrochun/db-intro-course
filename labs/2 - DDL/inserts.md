INSERT INTO "user" (email, hashed_password, nickname, name) VALUES 
('kolya@kpi.ua', 'hash1', 'KolyaDev', 'Микола'),
('egor@kpi.ua', 'hash2', 'Barabash', 'Єгор'),
('ilya@kpi.ua', 'hash3', 'Ilusha', 'Ілля'),
('misha@kpi.ua', 'hash4', 'Misha', 'Міша');

INSERT INTO game (game_name) VALUES 
('Dota 2'),
('Brawl Stars');


INSERT INTO game_account (user_id, game_id, game_account_id) VALUES
((SELECT id FROM "user" WHERE nickname = 'KolyaDev'), (SELECT id FROM game WHERE game_name = 'Dota 2'), 'steam_kolya123'),
((SELECT id FROM "user" WHERE nickname = 'Barabash'), (SELECT id FROM game WHERE game_name = 'Dota 2'), 'steam_egor_pro'),
((SELECT id FROM "user" WHERE nickname = 'Ilusha'), (SELECT id FROM game WHERE game_name = 'Brawl Stars'), 'supercell_ilusha');


INSERT INTO team (name, max_team_players) VALUES 
('KPI Cyber Squad', 5),
('Solo Mix', 5);


INSERT INTO team_member (team_id, user_id) VALUES
((SELECT id FROM team WHERE name = 'KPI Cyber Squad'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev')),
((SELECT id FROM team WHERE name = 'KPI Cyber Squad'), (SELECT id FROM "user" WHERE nickname = 'Barabash')),
((SELECT id FROM team WHERE name = 'Solo Mix'), (SELECT id FROM "user" WHERE nickname = 'Ilusha'));


INSERT INTO team_member_role (team_member_id, role) VALUES
(
    (SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND user_id = (SELECT id FROM "user" WHERE nickname = 'KolyaDev')), 
    'captain'
),
(
    (SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND user_id = (SELECT id FROM "user" WHERE nickname = 'Barabash')), 
    'player'
);


INSERT INTO tournament (game_id, organizer_id, name, min_teams, max_teams, min_team_players, max_team_players, prize_pool) VALUES
(
    (SELECT id FROM game WHERE game_name = 'Dota 2'),
    (SELECT id FROM "user" WHERE nickname = 'KolyaDev'),
    'KPI Autumn Major', 2, 8, 2, 5, 1000.00
);


INSERT INTO tournament_application (tournament_id, team_id, status) VALUES
(
    (SELECT id FROM tournament WHERE name = 'KPI Autumn Major'),
    (SELECT id FROM team WHERE name = 'KPI Cyber Squad'),
    'accepted'
),
(
    (SELECT id FROM tournament WHERE name = 'KPI Autumn Major'),
    (SELECT id FROM team WHERE name = 'Solo Mix'),
    'accepted'
);


INSERT INTO tournament_application_member (tournament_id, tournament_application_id, user_id) VALUES
(
    (SELECT id FROM tournament WHERE name = 'KPI Autumn Major'),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND tournament_id = (SELECT id FROM tournament WHERE name = 'KPI Autumn Major')),
    (SELECT id FROM "user" WHERE nickname = 'KolyaDev')
),
(
    (SELECT id FROM tournament WHERE name = 'KPI Autumn Major'),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND tournament_id = (SELECT id FROM tournament WHERE name = 'KPI Autumn Major')),
    (SELECT id FROM "user" WHERE nickname = 'Barabash')
);


INSERT INTO encounter (tournament_id, stage, tournament_application_id_1, tournament_application_id_2, max_matches) VALUES
(
    (SELECT id FROM tournament WHERE name = 'KPI Autumn Major'),
    'Grand Final',
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad')),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Solo Mix')),
    3
);


INSERT INTO "match" (match_game_id, encounter_id, map_order) VALUES
(
    'dota_match_1001',
    (SELECT id FROM encounter WHERE stage = 'Grand Final' AND tournament_id = (SELECT id FROM tournament WHERE name = 'KPI Autumn Major')),
    1
);


INSERT INTO player_statistic (match_id, user_id, kills, deaths, assists) VALUES
(
    (SELECT id FROM "match" WHERE match_game_id = 'dota_match_1001'),
    (SELECT id FROM "user" WHERE nickname = 'KolyaDev'),
    12, 3, 15
),
(
    (SELECT id FROM "match" WHERE match_game_id = 'dota_match_1001'),
    (SELECT id FROM "user" WHERE nickname = 'Barabash'),
    5, 8, 20
);