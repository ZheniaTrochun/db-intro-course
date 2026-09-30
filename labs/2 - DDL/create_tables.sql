create type sports_title as enum (
	'NONE',
	'THIRD_CATEGORY',
	'SECOND_CATEGORY',
	'FIRST_CATEGORY',
	'CANDIDATE_MASTER_OF_SPORTS',
	'MASTER_OF_SPORTS',
	'INTERNATIONAL_MASTER_OF_SPORTS',
	'HONORED_MASTER_OF_SPORTS'
);

create type table_type as enum (
	'PYRAMID_12FT',
	'PYRAMID_10FT',
	'POOL_9FT',
	'POOL_8FT',
	'SNOOKER_12FT',
	'CARAMBOLE'
);

create type table_status as enum (
	'AVAILABLE',
	'OCCUPIED',
	'RESERVED',
	'MAINTENANCE'
);

create type discipline as enum  (
	'POOL_8_BALL',
	'POOL_9_BALL',
	'SNOOKER',
	'FREE_PYRAMID',
	'COMBINED_PYRAMID',
	'DYNAMIC_PYRAMID',
	'CARAMBOLE'
);

create type format as enum  (
	'SINGLE_ELIMINATION',
	'DOUBLE_ELIMINATION',
	'ROUND_ROBIN'
);

create type tournament_status as enum  (
	'ANNOUNCED',
	'REGISTRATION_OPEN',
	'ONGOING',
	'FINISHED'
);

create type match_stage as enum  (
	'QUALIFICATION',
	'GROUP_STAGE',
	'ROUND_OF_64',
	'ROUND_OF_32',
	'ROUND_OF_16',
	'QUARTERFINAL',
	'SEMIFINAL',
	'FINAL',
	'THIRD_PLACE'
);

create type match_status as enum (
	'SCHEDULED',
	'IN_PROGRESS',
	'COMPLETED',
	'WALKOVER',
	'CANCELLED'
);

create type payment_status as enum (
	'PENDING',
	'PAID',
	'WAIVED',
	'REFUNDED'
);

create type participant_side as enum (
	'SIDE_1',
	'SIDE_2',
	'SIDE_3',
	'SIDE_4'
);

create table users (
	user_id int generated always as identity primary key,
	first_name varchar(100) not null,
	last_name varchar(100) not null,
	email varchar(320) not null unique,
	password_hash varchar(255) not null,
	date_of_birth date not null,
	created_at timestamptz not null default current_timestamp,
	deleted_at timestamptz default null,

	constraint chk_email_format check (
        email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
	constraint chk_user_dob check (
        date_of_birth <= current_date and date_of_birth >= '1900-01-01'
    )
);

create table player (
	player_id int generated always as identity primary key,
	person_id int not null unique references users(user_id) on delete cascade,
	rating int,
	sports_title sports_title not null default 'NONE',
	created_at timestamptz not null default current_timestamp,

	constraint chk_player_rating check (rating is null or rating >= 0)
);

create table club (
	club_id int generated always as identity primary key,
	club_name varchar(100) not null,
	city varchar(100) not null,
	address varchar(200) not null,
	created_at timestamptz not null default current_timestamp
);

create table billiard_table (
	table_id int generated always as identity primary key,
	club_id int not null references club(club_id) on delete cascade,
	table_number smallint not null,
	table_type table_type not null,
	table_status table_status not null,
	created_at timestamptz not null default current_timestamp,

	constraint uq_billiard_table_club_number unique (club_id, table_number),
	constraint chk_table_number_positive check (table_number > 0)
);

create table tournament (
	tournament_id int generated always as identity primary key,
	club_id int not null references club(club_id) on delete restrict,
	director_id int not null references users(user_id) on delete restrict,
	tournament_name varchar(150) not null,
	max_participants smallint not null,
	entry_fee numeric(10, 2) not null default 0.00,
	prize_pool numeric(10, 2) not null default 0.00,
	discipline discipline not null,
	format format not null,
	tournament_status tournament_status not null default 'ANNOUNCED',
	registration_deadline timestamptz not null,
	start_date timestamptz not null,
	end_date timestamptz,
	created_at timestamptz not null default current_timestamp,

	constraint chk_tournament_entry_fee_non_negative check (entry_fee >= 0),
	constraint chk_tournament_prize_pool_non_negative check (prize_pool >= 0),
	constraint chk_tournament_max_participants check (max_participants >= 2),
	constraint chk_tournament_dates check (end_date is null or start_date <= end_date),
	constraint chk_tournament_registration_deadline check (registration_deadline <= start_date)
);

create index idx_tournament_club_id on tournament (club_id);
create index idx_tournament_director_id on tournament (director_id);


create table match (
	match_id int generated always as identity primary key,
	tournament_id int not null references tournament(tournament_id) on delete cascade,
	table_id int references billiard_table(table_id) on delete set null,
	stage match_stage not null,
	race_to_frames smallint,
	race_to_points smallint,
	time_limit_minutes smallint,
	match_status match_status not null default 'SCHEDULED',
	scheduled_at timestamptz,
	started_at timestamptz,
	finished_at timestamptz,
	created_at timestamptz not null default current_timestamp,

	constraint chk_match_race_target check (
		num_nonnulls(race_to_frames, race_to_points) = 1
	),
	constraint chk_match_race_positive check (
		(race_to_frames is null or race_to_frames > 0) and
		(race_to_points is null or race_to_points > 0)
	),
	constraint chk_time_limit_minutes_positive check (
		(time_limit_minutes is null or time_limit_minutes > 0)
	),
	constraint chk_match_timeline check (
		started_at is null or finished_at is null or started_at <= finished_at
	),

	constraint chk_match_lifecycle_dates check (
        (match_status = 'SCHEDULED' and started_at is null and finished_at is null) or
        (match_status = 'IN_PROGRESS' and started_at is not null and finished_at is null) or
        (match_status = 'COMPLETED' and started_at is not null and finished_at is not null) or
        (match_status in ('WALKOVER', 'CANCELLED'))
    )
);

create index idx_match_tournament_id on match (tournament_id);
create index idx_match_table_id on match (table_id);

create table team (
	team_id int generated always as identity primary key,
	team_name varchar(100) not null,
	captain_id int not null references player(player_id) on delete restrict,
	created_at timestamptz not null default current_timestamp,

	constraint uq_team_name unique (team_name),
	constraint chk_team_name_not_empty check (length(trim(team_name)) > 0)
);

create index idx_team_captain_id on team (captain_id);

create table team_member (
	team_id int not null references team(team_id) on delete cascade,
    player_id int not null references player(player_id) on delete cascade,
	joined_at timestamptz not null default current_timestamp,

	primary key (team_id, player_id)
);

create index idx_team_member_player_id on team_member (player_id);

create table tournament_registration (
	tournament_registration_id int generated always as identity primary key,
	tournament_id int not null references tournament(tournament_id) on delete cascade,
	player_id int references player(player_id) on delete restrict,
	team_id int references team(team_id) on delete restrict,
	seed_number smallint,
	payment_status payment_status not null default 'PENDING',
	final_placement smallint,
	prize_won numeric(10, 2) not null default 0.00,
	registered_at timestamptz not null default current_timestamp,

	constraint chk_registration_participant check (
            num_nonnulls(player_id, team_id) = 1
    ),
		
	constraint uq_registration_tournament_player unique (tournament_id, player_id),
	constraint uq_registration_tournament_team unique (tournament_id, team_id),
	constraint uq_registration_tournament_seed unique (tournament_id, seed_number),
	
	constraint chk_registration_seed_positive check (
		seed_number is null or seed_number > 0
	),
	constraint chk_registration_placement_positive check (
		final_placement is null or final_placement > 0
	),
	constraint chk_registration_prize_non_negative check (
		prize_won >= 0
	),

	constraint chk_registration_prize_requires_placement check (
        prize_won = 0 or final_placement is not null
    )
);

create index idx_tournament_registration_tournament_id on tournament_registration (tournament_id);
create index idx_tournament_registration_player_id on tournament_registration (player_id);
create index idx_tournament_registration_team_id on tournament_registration (team_id);

create table match_participant (
	match_participant_id int generated always as identity primary key,
	match_id int not null references match(match_id) on delete cascade,
	player_id int references player(player_id) on delete restrict,
	team_id int references team(team_id) on delete restrict,
	frames_won smallint,
	points smallint,
	side participant_side not null,
	is_winner boolean not null default false,
	created_at timestamptz not null default current_timestamp,

	constraint chk_match_participant check (
		num_nonnulls(player_id, team_id) = 1
	),
	
	constraint chk_participant_score_target check (
		num_nonnulls(frames_won, points) <= 1
	),
	constraint chk_participant_score_positive check (
		(frames_won is null or frames_won >= 0) and
		(points is null or points >= 0)
	),
	
	constraint uq_match_participant_side unique (match_id, side),
	constraint uq_match_participant_player unique (match_id, player_id),
    constraint uq_match_participant_team unique (match_id, team_id)
	
);

create index idx_match_participant_player_id on match_participant (player_id);
create index idx_match_participant_team_id on match_participant (team_id);

create unique index uq_match_single_winner
on match_participant (match_id)
where is_winner = true;

