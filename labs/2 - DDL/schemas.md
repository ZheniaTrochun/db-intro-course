create type team_status as enum ('active', 'disbanded');
create type team_member_status as enum ('active', 'left', 'kicked');
create type tournament_status as enum ('registration', 'ongoing', 'finished');
create type tournament_participant_status as enum ('pending', 'accepted', 'rejected');
create type encounter_status as enum ('ongoing', 'scheduled', 'finished');
create type team_role as enum ('player', 'captain');

create table "user" (
    id uuid primary key default gen_random_uuid(),
    email varchar(100) unique not null,
    hashed_password text not null,
    nickname varchar(20) unique not null,
    name varchar(20),
    description text,
    avatar_url text,
    created_at timestamp not null default now()
);

create table game (
    id uuid primary key default gen_random_uuid(),
    game_name varchar(30) unique not null,
    logo_url text
);

create table game_account (
    user_id uuid references "user"(id) not null,
    game_id uuid references game(id) not null,
    game_account_id text unique not null,
    primary key (user_id, game_id)
);

create table team (
    id uuid primary key default gen_random_uuid(),
    name varchar(20) unique not null,
    avatar_url text,
    created_at timestamp not null default now(),
    max_team_players smallint,
    status team_status not null default 'active'
);

create table team_member (
    id uuid primary key default gen_random_uuid(),
    team_id uuid references team(id) not null,
    user_id uuid references "user"(id) not null,
    joined_at timestamp not null default now(),
    leave_at timestamp,
    status team_member_status not null default 'active'
);

create table team_member_role (
    id uuid primary key default gen_random_uuid(),
    team_member_id uuid references team_member(id) not null,
    role team_role not null
);

create table tournament (
    id uuid primary key default gen_random_uuid(),
    game_id uuid references game(id) not null,
    organizer_id uuid references "user"(id) not null,
    created_at timestamp not null default now(),
    start_at timestamp,
    name varchar(30) not null,
    prize_pool decimal(10,2),
    currency varchar(15),
    max_teams smallint,
    min_teams smallint,
    min_team_players smallint not null,
    max_team_players smallint,
    status tournament_status not null default 'registration',
    check (max_teams >= min_teams),
    check (max_team_players >= min_team_players)
);

create table tournament_application (
    id uuid primary key default gen_random_uuid(),
    tournament_id uuid references tournament(id) not null,
    team_id uuid references team(id) not null,
    status tournament_participant_status not null default 'pending',
    unique(tournament_id, team_id)
);

create table tournament_application_member (
    tournament_id uuid references tournament(id) not null,
    tournament_application_id uuid references tournament_application(id) not null,
    user_id uuid references "user"(id) not null,
    primary key (tournament_id, user_id)
);

create table encounter (
    id uuid primary key default gen_random_uuid(),
    tournament_id uuid references tournament(id) not null,
    stage varchar(15) not null,
    tournament_application_id_1 uuid references tournament_application(id),
    tournament_application_id_2 uuid references tournament_application(id),
    winner_tournament_application_id uuid references tournament_application(id),
    next_encounter_id uuid references encounter(id),
    max_matches smallint not null,
    status encounter_status not null default 'scheduled'
);

create table "match" (
    id uuid primary key default gen_random_uuid(),
    match_game_id text not null,
    encounter_id uuid references encounter(id) not null,
    map_order smallint not null,
    winner_tournament_application_id uuid references tournament_application(id),
    unique(encounter_id, map_order)
);

create table player_statistic (
    match_id uuid references "match"(id) not null,
    user_id uuid references "user"(id) not null,
    kills smallint,
    deaths smallint,
    assists smallint,
    primary key (match_id, user_id)
);