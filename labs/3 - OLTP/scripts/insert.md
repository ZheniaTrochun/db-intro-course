Мета: Зробити запит який додасть до кожної існуючої таблиці щонайменше три рядки даних

Використовувалися команди: INSERT та SELECT і оператори: WHERE та AND. Для того щоб одним запитом заповнити усі таблиці, використовувалися вкладені запити, щоб динамічно витягувати дані з інших таблиць, знаючи значення певного атрибуту запису іншої таблиці

INSERT INTO "user" (email, hashed_password, nickname, name)
VALUES 
('kolya@gmail.com', 'abc1', 'pro228', 'kolya'),
('illya@gmail.com', 'abc2', 'hacker228', 'illya'),
('barunь@gmail.com', 'abc3', 'barabashik-25', 'barik');

INSERT INTO game (game_name)
VALUES
('dota2'),
('counter strike2'),
('valorant');

INSERT INTO game_account (user_id, game_id, game_account_id)
VALUES
( (SELECT id FROM "user" WHERE nickname = 'pro228'), (SELECT id FROM game WHERE game_name = 'counter strike2'), '123' ),
( (SELECT id FROM "user" WHERE nickname = 'hacker228'), (SELECT id FROM game WHERE game_name = 'valorant'), '124' ),
( (SELECT id FROM "user" WHERE nickname = 'barabashik-25'), (SELECT id FROM game WHERE game_name = 'dota2'), '125' );


INSERT INTO team (name, max_team_players) 
VALUES 
('NAVI', 5), 
('Fnatic', 5), 
('Cloud9', 5);


INSERT INTO team_member (team_id, user_id) 
VALUES 
( (SELECT id FROM team WHERE name = 'NAVI'), (SELECT id FROM "user" WHERE nickname = 'pro228') ),
( (SELECT id FROM team WHERE name = 'Fnatic'), (SELECT id FROM "user" WHERE nickname = 'hacker228') ),
( (SELECT id FROM team WHERE name = 'Cloud9'), (SELECT id FROM "user" WHERE nickname = 'barabashik-25') );


INSERT INTO team_member_role (team_member_id, role) 
VALUES 
( (SELECT id FROM team_member WHERE user_id = (SELECT id FROM "user" WHERE nickname = 'pro228')), 'captain' ),
( (SELECT id FROM team_member WHERE user_id = (SELECT id FROM "user" WHERE nickname = 'hacker228')), 'captain' ),
( (SELECT id FROM team_member WHERE user_id = (SELECT id FROM "user" WHERE nickname = 'barabashik-25')), 'captain' );


INSERT INTO tournament (game_id, organizer_id, name, prize_pool, currency, min_teams, max_teams, min_team_players, max_team_players) 
VALUES 
( (SELECT id FROM game WHERE game_name = 'counter strike2'), (SELECT id FROM "user" WHERE nickname = 'pro228'), 'CS2 Major', 10000, 'USD', 8, 24, 5, 8 ),
( (SELECT id FROM game WHERE game_name = 'valorant'), (SELECT id FROM "user" WHERE nickname = 'hacker228'), 'Valorant Cup', 5000, 'EUR', 12, 32, 5, 7 ),
( (SELECT id FROM game WHERE game_name = 'dota2'), (SELECT id FROM "user" WHERE nickname = 'barabashik-25'), 'Dota 2 TI', 20000, 'USD', 4, 16, 5, 9 );


INSERT INTO tournament_application (tournament_id, team_id, status) 
VALUES 
( (SELECT id FROM tournament WHERE name = 'CS2 Major'), (SELECT id FROM team WHERE name = 'NAVI'), 'accepted' ),
( (SELECT id FROM tournament WHERE name = 'CS2 Major'), (SELECT id FROM team WHERE name = 'Fnatic'), 'accepted' ),
( (SELECT id FROM tournament WHERE name = 'CS2 Major'), (SELECT id FROM team WHERE name = 'Cloud9'), 'accepted' );


INSERT INTO tournament_application_member (tournament_id, tournament_application_id, user_id) 
VALUES 
(
    (SELECT id FROM tournament WHERE name = 'CS2 Major'),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    (SELECT id FROM "user" WHERE nickname = 'pro228')
),
(
    (SELECT id FROM tournament WHERE name = 'CS2 Major'),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Fnatic') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    (SELECT id FROM "user" WHERE nickname = 'hacker228')
),
(
    (SELECT id FROM tournament WHERE name = 'CS2 Major'),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Cloud9') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    (SELECT id FROM "user" WHERE nickname = 'barabashik-25')
);


INSERT INTO encounter (tournament_id, stage, tournament_application_id_1, tournament_application_id_2, max_matches) 
VALUES 
(
    (SELECT id FROM tournament WHERE name = 'CS2 Major'),
    'Semi-final 1',
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Fnatic') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    3
),
(
    (SELECT id FROM tournament WHERE name = 'CS2 Major'),
    'Semi-final 2',
    (SELECT id FROM tournament_application WHERE team_id = (SELECT id FROM team WHERE name = 'Cloud9') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    NULL, 
    3
),
(
    (SELECT id FROM tournament WHERE name = 'CS2 Major'),
    'Final',
    NULL, 
    NULL,
    5
);


INSERT INTO "match" (match_game_id, encounter_id, map_order) 
VALUES 
(
    'match_001',
    (SELECT id FROM encounter WHERE stage = 'Semi-final 1' AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    1
),
(
    'match_002',
    (SELECT id FROM encounter WHERE stage = 'Semi-final 1' AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    2
),
(
    'match_003',
    (SELECT id FROM encounter WHERE stage = 'Semi-final 1' AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')),
    3
);


INSERT INTO player_statistic (match_id, user_id, kills, deaths, assists) 
VALUES 
(
    (SELECT id FROM "match" WHERE match_game_id = 'match_001'),
    (SELECT id FROM "user" WHERE nickname = 'pro228'),
    25, 10, 5
),
(
    (SELECT id FROM "match" WHERE match_game_id = 'match_001'),
    (SELECT id FROM "user" WHERE nickname = 'hacker228'),
    12, 20, 3
),
(
    (SELECT id FROM "match" WHERE match_game_id = 'match_002'),
    (SELECT id FROM "user" WHERE nickname = 'pro228'),
    30, 8, 4
);
	   
	