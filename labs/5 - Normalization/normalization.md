1. Знайдена проблема дублювання стовпців у таблиці encounter, дублюється tournament_application_id що порушує 1 NF
Рішення: зробити таблицю encounter_application яка буде містити encounter_id та один tournament_application_id, туди ж буде доданий булевий атрибут is_winner, який буде показувати чи виграла команда-учасник цю зустіч.

alter table encounter
    drop constraint duplication_check,
    drop column tournament_application_id_1,
    drop column tournament_application_id_2,
    drop column winner_tournament_application_id;

create table encounter_participant (
    encounter_id uuid references encounter(id) on delete cascade not null,
    tournament_application_id uuid references tournament_application(id) on delete set null,
    is_winner boolean not null default false,
    primary key (encounter_id, tournament_application)
);
Тепер 1 NF дотримана

Функціональні залежності:
user:
id-> email
id-> hashed password
id-> nickname
id-> name
id-> desciption
id-> avatar_url
id-> created_at
id-> status
email-> id
nickname-> id

game:
id-> game_name
id-> logo_url
game_name-> id

game_account:
(user_id, game_id)-> game_account_id
game_account_id-> user_id
game_account_id-> game_id

team:
id-> name
id-> avatar_url
id-> created_at
id-> max_team_players
id-> status
name->id

team_member: 
id-> team_id
id-> user_id
id-> joined_at
id-> leave_at
id-> status
(team_id, user_id)-> id


team_member_role:
id-> team_member_id
id-> role

tournament:
id-> game_id 
id-> organizer_id 
id-> created_at
id-> start_at 
id-> name 
id-> prize_pool 
id-> currency
id-> max_teams 
id-> min_teams 
id-> min_team_players 
id-> max_team_players 
id-> status

tournament_application:
id-> tournament_id
id-> team_id
id-> status
(tournament_id, team_id)-> id


tournament_application_member:
(tournament_id, user_id)-> tournament_application_id
tournament_application_id-> tournament_id


encounter:
id-> tournament_id
id-> stage
id-> next_encounter_id
id-> max_matches
id-> status

encounter_participant:
(encounter_id, tournament_application_id)-> isWinner

match:
id-> match_game_id
id-> encounter_id
id-> map_order
id-> winner_tournament_application_id
match_game_id-> id
(encounter_id, map_order)-> id

player_statistic:
(match_id, user_id)-> kills
(match_id, user_id)-> deaths
(match_id, user_id)-> assists

Немає жодних залежностей неключових атрибутів від частини кандидат ключа - NF2 дотримана, немаємо жодних залежностей неключових атрибутів від інших неключових атрибутів - NF3 дотримана.

2. З цікавого є недотримання форми BCNF у таблиці tournament_application_member, атрибут tournament_id залежить від атрибуту tournament_application_id, який не є суперключом.
Рішення: видалити поле tournament_id з таблиці tournament_application_member

alter table tournament_application_member
    drop column tournament_id;
    drop constraint tournament_application_member_pkey