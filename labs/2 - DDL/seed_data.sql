insert into users (user_id, first_name, last_name, email, password_hash, date_of_birth)
overriding system value
values
    (1, 'Дмитро',    'Білозеров',     'bilozorov@example.com',     '$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe', '1994-07-28'),
    (2, 'Олександр', 'Паламар',       'palamar@example.com',       '$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe', '1987-06-15'),
    (3, 'Сергій',    'Крижановський', 'kryzhanovskyi@example.com', '$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe', '1997-07-06'),
    (4, 'Євген',     'Сталєв',        'stalev@example.com',        '$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe', '1979-05-19'),
    (5, 'Андрій',    'Шевченко',      'shevchenko@example.com',    '$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe', '1980-01-30');

select setval(pg_get_serial_sequence('users', 'user_id'), (select max(user_id) from users));

insert into player (player_id, person_id, rating, sports_title)
overriding system value
values
    (1, 1, 2600, 'INTERNATIONAL_MASTER_OF_SPORTS'),
    (2, 2, 2500, 'HONORED_MASTER_OF_SPORTS'),
    (3, 3, 2450, 'INTERNATIONAL_MASTER_OF_SPORTS'),
    (4, 4, 2550, 'HONORED_MASTER_OF_SPORTS');

select setval(pg_get_serial_sequence('player', 'player_id'), (select max(player_id) from player));

insert into club (club_id, club_name, city, address)
overriding system value
values
    (1, 'Більярдний клуб "Піраміда"', 'Київ',  'вул. Хрещатик, 22'),
    (2, 'Brooklyn Billiards',         'Одеса', 'вул. Дерибасівська, 15'),
    (3, 'CueSport Arena',             'Харків', 'вул. Сумська, 48');

select setval(pg_get_serial_sequence('club', 'club_id'), (select max(club_id) from club));

insert into billiard_table (table_id, club_id, table_number, table_type, table_status)
overriding system value
values
    (1, 1, 1, 'PYRAMID_12FT', 'AVAILABLE'),
    (2, 1, 2, 'POOL_9FT',     'AVAILABLE'),
    (3, 1, 3, 'SNOOKER_12FT', 'MAINTENANCE'),
    (4, 2, 1, 'PYRAMID_12FT', 'AVAILABLE'),
    (5, 2, 2, 'POOL_8FT',     'OCCUPIED');

select setval(pg_get_serial_sequence('billiard_table', 'table_id'), (select max(table_id) from billiard_table));

insert into team (team_id, team_name, captain_id)
overriding system value
values
    (1, 'Київські Легенди',  2),
    (2, 'Чемпіони Піраміди', 1);

select setval(pg_get_serial_sequence('team', 'team_id'), (select max(team_id) from team));

insert into team_member (team_id, player_id)
values
    (1, 2),
    (1, 4),
    (2, 1),
    (2, 3);

insert into tournament (
    tournament_id, club_id, director_id, tournament_name, max_participants,
    entry_fee, prize_pool, discipline, format, tournament_status,
    registration_deadline, start_date, end_date
)
overriding system value
values
    (1, 1, 5,
     'Кубок Чемпіонів — Піраміда', 16,
     500.00, 30000.00, 'FREE_PYRAMID', 'SINGLE_ELIMINATION', 'ONGOING',
     '2026-09-01 18:00:00+03', '2026-09-15 10:00:00+03', null),

    (2, 2, 5,
     'Одеський Турнір — Пул 9-ка', 8,
     300.00, 12000.00, 'POOL_9_BALL', 'ROUND_ROBIN', 'ANNOUNCED',
     '2026-10-20 23:59:00+03', '2026-11-01 10:00:00+03', '2026-11-03 20:00:00+03'),

    (3, 1, 5,
     'Командна Битва Титанів', 8,
     1000.00, 50000.00, 'COMBINED_PYRAMID', 'SINGLE_ELIMINATION', 'REGISTRATION_OPEN',
     '2026-10-10 23:59:00+03', '2026-10-20 10:00:00+03', '2026-10-22 20:00:00+03');

select setval(pg_get_serial_sequence('tournament', 'tournament_id'), (select max(tournament_id) from tournament));

insert into tournament_registration (
    tournament_registration_id, tournament_id, player_id, team_id,
    seed_number, payment_status, final_placement, prize_won
)
overriding system value
values
    (1, 1, 1, null, 1, 'PAID',    1, 15000.00),
    (2, 1, 2, null, 2, 'PAID',    2,  9000.00),
    (3, 1, 3, null, 3, 'PAID',    3,  6000.00),
    (4, 1, 4, null, 4, 'PAID',    4,     0.00),
    (5, 2, 1, null, null, 'PAID',    null, 0.00),
    (6, 2, 2, null, null, 'PENDING', null, 0.00),
    (7, 2, 3, null, null, 'PENDING', null, 0.00),
    (8, 3, null, 1, null, 'PAID',    null, 0.00),
    (9, 3, null, 2, null, 'PENDING', null, 0.00);

select setval(pg_get_serial_sequence('tournament_registration', 'tournament_registration_id'),
    (select max(tournament_registration_id) from tournament_registration));

insert into match (
    match_id, tournament_id, table_id, stage,
    race_to_frames, race_to_points, time_limit_minutes,
    match_status, scheduled_at, started_at, finished_at
)
overriding system value
values
    (1, 1, 1, 'SEMIFINAL',
     5, null, 60,
     'COMPLETED',
     '2026-09-15 10:00:00+03', '2026-09-15 10:05:00+03', '2026-09-15 11:30:00+03'),

    (2, 1, 2, 'SEMIFINAL',
     5, null, 60,
     'COMPLETED',
     '2026-09-15 10:00:00+03', '2026-09-15 10:10:00+03', '2026-09-15 12:00:00+03'),

    (3, 1, 1, 'FINAL',
     7, null, 90,
     'COMPLETED',
     '2026-09-15 14:00:00+03', '2026-09-15 14:10:00+03', '2026-09-15 16:45:00+03');

select setval(pg_get_serial_sequence('match', 'match_id'), (select max(match_id) from match));

insert into match_participant (
    match_participant_id, match_id, player_id, team_id,
    frames_won, points, side, is_winner
)
overriding system value
values
    (1, 1, 1, null, 5, null, 'SIDE_1', true),
    (2, 1, 4, null, 3, null, 'SIDE_2', false),
    (3, 2, 2, null, 5, null, 'SIDE_1', true),
    (4, 2, 3, null, 4, null, 'SIDE_2', false),
    (5, 3, 1, null, 7, null, 'SIDE_1', true),
    (6, 3, 2, null, 5, null, 'SIDE_2', false);

select setval(pg_get_serial_sequence('match_participant', 'match_participant_id'),
    (select max(match_participant_id) from match_participant));
