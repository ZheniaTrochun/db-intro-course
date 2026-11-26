-- Дроп всіх існуючих данних з таблиці
TRUNCATE TABLE "user", game, game_account, team, team_member, team_member_role,
tournament, tournament_application, tournament_application_member, encounter, "match", player_statistic CASCADE;

INSERT INTO "user" (email, hashed_password, nickname, name, status) VALUES
('kolya@kpi.ua', 'hash1', 'KolyaDev', 'Микола', 'active'),
('egor@kpi.ua', 'hash2', 'Barabash', 'Єгор', 'active'),
('ilya@kpi.ua', 'hash3', 'Ilusha', 'Ілля', 'active'),
('misha@kpi.ua', 'hash4', 'Misha', 'Міша', 'active'),
('s1mple@mail.com', 'hash5', 's1mple', 'Oleksandr', 'active'),
('b1t@mail.com', 'hash6', 'b1t', 'Valeriy', 'active'),
('m0nesy@mail.com', 'hash7', 'm0nesy', 'Ilya', 'active'),
('niko@mail.com', 'hash8', 'NiKo', 'Nikola', 'active'),
('dendi@mail.com', 'hash9', 'Dendi', 'Danil', 'active'),
('toxic@mail.com', 'hash10', 'ToxicBoy', 'Ivan', 'banned'),
('admin@esports.com', 'hash11', 'MainAdmin', 'Admin', 'active');

INSERT INTO game (game_name) VALUES
('Dota 2'),
('Brawl Stars'),
('CS 2'),
('Valorant');

INSERT INTO game_account (user_id, game_id, game_account_id) VALUES
((SELECT id FROM "user" WHERE nickname = 'KolyaDev'), (SELECT id FROM game WHERE game_name = 'Dota 2'), 'steam_kolya123'),
((SELECT id FROM "user" WHERE nickname = 'Barabash'), (SELECT id FROM game WHERE game_name = 'Dota 2'), 'steam_egor_pro'),
((SELECT id FROM "user" WHERE nickname = 'Ilusha'), (SELECT id FROM game WHERE game_name = 'Brawl Stars'), 'supercell_ilusha'),
((SELECT id FROM "user" WHERE nickname = 's1mple'), (SELECT id FROM game WHERE game_name = 'CS 2'), 'steam_s1mple'),
((SELECT id FROM "user" WHERE nickname = 'b1t'), (SELECT id FROM game WHERE game_name = 'CS 2'), 'steam_b1t'),
((SELECT id FROM "user" WHERE nickname = 'm0nesy'), (SELECT id FROM game WHERE game_name = 'CS 2'), 'steam_m0nesy'),
((SELECT id FROM "user" WHERE nickname = 'NiKo'), (SELECT id FROM game WHERE game_name = 'CS 2'), 'steam_niko'),
((SELECT id FROM "user" WHERE nickname = 'Dendi'), (SELECT id FROM game WHERE game_name = 'Dota 2'), 'steam_dendi');

INSERT INTO team (name, max_team_players, status) VALUES 
('KPI Cyber Squad', 9, 'active'),
('Solo Mix', 7, 'active'),
('Natus Vincere', 12, 'active'),
('G2 Esports', 6, 'active'),
('B8 Esports', 13, 'active'),
('Cheaters Stack', 15, 'deleted');

INSERT INTO team_member (team_id, user_id, status) VALUES
((SELECT id FROM team WHERE name = 'KPI Cyber Squad'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev'), 'active'),
((SELECT id FROM team WHERE name = 'KPI Cyber Squad'), (SELECT id FROM "user" WHERE nickname = 'Barabash'), 'active'),
((SELECT id FROM team WHERE name = 'Solo Mix'), (SELECT id FROM "user" WHERE nickname = 'Ilusha'), 'active'),
((SELECT id FROM team WHERE name = 'Natus Vincere'), (SELECT id FROM "user" WHERE nickname = 's1mple'), 'active'),
((SELECT id FROM team WHERE name = 'Natus Vincere'), (SELECT id FROM "user" WHERE nickname = 'b1t'), 'active'),
((SELECT id FROM team WHERE name = 'G2 Esports'), (SELECT id FROM "user" WHERE nickname = 'm0nesy'), 'active'),
((SELECT id FROM team WHERE name = 'G2 Esports'), (SELECT id FROM "user" WHERE nickname = 'NiKo'), 'active'),
((SELECT id FROM team WHERE name = 'B8 Esports'), (SELECT id FROM "user" WHERE nickname = 'Dendi'), 'active'),
((SELECT id FROM team WHERE name = 'Cheaters Stack'), (SELECT id FROM "user" WHERE nickname = 'ToxicBoy'), 'kicked');

INSERT INTO team_member_role (team_member_id, role) VALUES
((SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND user_id = (SELECT id FROM "user" WHERE nickname = 'KolyaDev')), 'captain'),
((SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND user_id = (SELECT id FROM "user" WHERE nickname = 'Barabash')), 'player'),
((SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'Natus Vincere') AND user_id = (SELECT id FROM "user" WHERE nickname = 's1mple')), 'captain'),
((SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'G2 Esports') AND user_id = (SELECT id FROM "user" WHERE nickname = 'NiKo')), 'captain'),
((SELECT id FROM team_member WHERE team_id = (SELECT id FROM team WHERE name = 'B8 Esports') AND user_id = (SELECT id FROM "user" WHERE nickname = 'Dendi')), 'captain');

INSERT INTO tournament (game_id, organizer_id, name, min_teams, max_teams, min_team_players, max_team_players, prize_pool, currency, status) VALUES
((SELECT id FROM game WHERE game_name = 'Dota 2'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev'), 'KPI Autumn Major', 2, 8, 2, 5, 1000.00, 'UAH', 'finished'),
((SELECT id FROM game WHERE game_name = 'CS 2'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'CS2 Major Kyiv', 2, 16, 2, 5, 500000.00, 'USD', 'finished'),
((SELECT id FROM game WHERE game_name = 'Dota 2'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'Dota 2 The International', 4, 32, 2, 5, 2500000.00, 'USD', 'registration'),
((SELECT id FROM game WHERE game_name = 'Brawl Stars'), (SELECT id FROM "user" WHERE nickname = 'Ilusha'), 'Brawl Stars City Cup', 2, 16, 1, 3, 500.00, 'EUR', 'finished'),
((SELECT id FROM game WHERE game_name = 'Valorant'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'Valorant Champions Tour', 4, 16, 5, 7, 1000000.00, 'USD', 'ongoing'),
((SELECT id FROM game WHERE game_name = 'CS 2'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev'), 'KPI Spring Cup', 2, 8, 5, 5, 15000.00, 'UAH', 'registration'),
((SELECT id FROM game WHERE game_name = 'Dota 2'), (SELECT id FROM "user" WHERE nickname = 's1mple'), 'European Pro League', 4, 16, 5, 5, 50000.00, 'EUR', 'ongoing'),
((SELECT id FROM game WHERE game_name = 'Brawl Stars'), (SELECT id FROM "user" WHERE nickname = 'Barabash'), 'Amateur Weekly Brawl', 2, 8, 1, 3, 2000.00, 'UAH', 'finished'),
((SELECT id FROM game WHERE game_name = 'CS 2'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'CS2 Blast Premier', 4, 8, 5, 6, 425000.00, 'EUR', 'finished'),
((SELECT id FROM game WHERE game_name = 'Valorant'), (SELECT id FROM "user" WHERE nickname = 'b1t'), 'Valorant Challengers EMEA', 4, 12, 5, 6, 200000.00, 'EUR', 'ongoing'),
((SELECT id FROM game WHERE game_name = 'Dota 2'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'Dota 2 Riyadh Masters', 8, 20, 5, 7, 15000000.00, 'USD', 'finished'),
((SELECT id FROM game WHERE game_name = 'CS 2'), (SELECT id FROM "user" WHERE nickname = 'm0nesy'), 'CS2 IEM Cologne', 8, 24, 5, 6, 1000000.00, 'USD', 'registration'),
((SELECT id FROM game WHERE game_name = 'Brawl Stars'), (SELECT id FROM "user" WHERE nickname = 'Ilusha'), 'Brawl Stars World Finals', 8, 16, 3, 4, 1000000.00, 'USD', 'ongoing'),
((SELECT id FROM game WHERE game_name = 'CS 2'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev'), 'Ukrainian Esports League', 4, 16, 5, 5, 100000.00, 'UAH', 'ongoing'),
((SELECT id FROM game WHERE game_name = 'Valorant'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'Valorant Game Changers', 4, 8, 5, 6, 500000.00, 'USD', 'finished'),
((SELECT id FROM game WHERE game_name = 'Dota 2'), (SELECT id FROM "user" WHERE nickname = 'Dendi'), 'Dota 2 DreamLeague', 8, 16, 5, 6, 1000000.00, 'EUR', 'ongoing'),
((SELECT id FROM game WHERE game_name = 'CS 2'), (SELECT id FROM "user" WHERE nickname = 'MainAdmin'), 'CS2 ESL Pro League', 16, 32, 5, 7, 750000.00, 'EUR', 'registration'),
((SELECT id FROM game WHERE game_name = 'Brawl Stars'), (SELECT id FROM "user" WHERE nickname = 'Barabash'), 'Brawl Monthly Qualifier', 4, 32, 3, 3, 5000.00, 'PLN', 'finished'),
((SELECT id FROM game WHERE game_name = 'Valorant'), (SELECT id FROM "user" WHERE nickname = 'NiKo'), 'Valorant Masters Tokyo', 8, 12, 5, 6, 1000000.00, 'JPY', 'finished'),
((SELECT id FROM game WHERE game_name = 'Dota 2'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev'), 'Dota 2 ESL One', 4, 12, 5, 6, 300000.00, 'GBP', 'ongoing');

INSERT INTO tournament_application (tournament_id, team_id, status) VALUES
((SELECT id FROM tournament WHERE name = 'KPI Autumn Major'), (SELECT id FROM team WHERE name = 'KPI Cyber Squad'), 'accepted'),
((SELECT id FROM tournament WHERE name = 'KPI Autumn Major'), (SELECT id FROM team WHERE name = 'Solo Mix'), 'accepted'),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM team WHERE name = 'Natus Vincere'), 'accepted'),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM team WHERE name = 'G2 Esports'), 'accepted'),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM team WHERE name = 'Cheaters Stack'), 'rejected'),
((SELECT id FROM tournament WHERE name = 'Dota 2 The International'), (SELECT id FROM team WHERE name = 'B8 Esports'), 'pending');

INSERT INTO tournament_application_member (tournament_id, tournament_application_id, user_id) VALUES
((SELECT id FROM tournament WHERE name = 'KPI Autumn Major'), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND tournament_id = (SELECT id FROM tournament WHERE name = 'KPI Autumn Major')), (SELECT id FROM "user" WHERE nickname = 'KolyaDev')),
((SELECT id FROM tournament WHERE name = 'KPI Autumn Major'), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad') AND tournament_id = (SELECT id FROM tournament WHERE name = 'KPI Autumn Major')), (SELECT id FROM "user" WHERE nickname = 'Barabash')),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Natus Vincere') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), (SELECT id FROM "user" WHERE nickname = 's1mple')),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Natus Vincere') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), (SELECT id FROM "user" WHERE nickname = 'b1t')),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'G2 Esports') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), (SELECT id FROM "user" WHERE nickname = 'm0nesy')),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'G2 Esports') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), (SELECT id FROM "user" WHERE nickname = 'NiKo'));

INSERT INTO encounter (tournament_id, stage, tournament_application_id_1, tournament_application_id_2, max_matches, status) VALUES
((SELECT id FROM tournament WHERE name = 'KPI Autumn Major'), 'Grand Final', (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'KPI Cyber Squad')), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Solo Mix')), 3, 'finished'),
((SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv'), 'Grand Final', (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Natus Vincere') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'G2 Esports') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), 3, 'finished');

INSERT INTO "match" (match_game_id, encounter_id, map_order) VALUES
('dota_match_1001', (SELECT id FROM encounter WHERE stage = 'Grand Final' AND tournament_id = (SELECT id FROM tournament WHERE name = 'KPI Autumn Major')), 1),
('cs2_match_final_1', (SELECT id FROM encounter WHERE stage = 'Grand Final' AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), 1),
('cs2_match_final_2', (SELECT id FROM encounter WHERE stage = 'Grand Final' AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major Kyiv')), 2);

INSERT INTO player_statistic (match_id, user_id, kills, deaths, assists) VALUES
((SELECT id FROM "match" WHERE match_game_id = 'dota_match_1001'), (SELECT id FROM "user" WHERE nickname = 'KolyaDev'), 12, 3, 15),
((SELECT id FROM "match" WHERE match_game_id = 'dota_match_1001'), (SELECT id FROM "user" WHERE nickname = 'Barabash'), 5, 8, 20),
((SELECT id FROM "match" WHERE match_game_id = 'cs2_match_final_1'), (SELECT id FROM "user" WHERE nickname = 's1mple'), 28, 12, 5),
((SELECT id FROM "match" WHERE match_game_id = 'cs2_match_final_1'), (SELECT id FROM "user" WHERE nickname = 'b1t'), 15, 14, 8),
((SELECT id FROM "match" WHERE match_game_id = 'cs2_match_final_1'), (SELECT id FROM "user" WHERE nickname = 'm0nesy'), 25, 15, 3),
((SELECT id FROM "match" WHERE match_game_id = 'cs2_match_final_1'), (SELECT id FROM "user" WHERE nickname = 'NiKo'), 18, 18, 5),
((SELECT id FROM "match" WHERE match_game_id = 'cs2_match_final_2'), (SELECT id FROM "user" WHERE nickname = 's1mple'), 20, 15, 6),
((SELECT id FROM "match" WHERE match_game_id = 'cs2_match_final_2'), (SELECT id FROM "user" WHERE nickname = 'm0nesy'), 30, 10, 2);


