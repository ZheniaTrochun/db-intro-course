# Сутності:

## player:

Таблиця з інформацією про гравця

`player_id` - (IDENTITY) - Ідентифікатор гравця **(PK)**
`nickname` - (TEXT) - Ігровий псевдонім **UNIQUE**
`first_name` - (TEXT) - Ім’я гравця
`last_name` - (TEXT) - Прізвище гравця
`country` - (ENUM) - Країна яку гравець представляє
`date_of_birth` - (DATE) - Дата народження

#### player - team_player (1:N/0)

Один гравець може бути учасником багатьох команд або жодної команди
Показує гравця як учасника команди

## team_player:

Таблиця яка зберігає інформацію про гравця як учсника команди

`team_player_id` - (IDENTITY) - Ідентифікатор учасника команди **(PK)**
`player_id` - Ідентифікатор гравця, позичений з таблиці Players **(FK)**
`game_team_id` - Ідентифікатор команди по грі, позичений з таблиці Game Team **(FK)**
`join_date` - Дата приєднання до команди
`leave_date` - Дата виходу з команди (якщо був)
`role` - Роль у команді

## game_team:

У цій таблиці зберігаються команди які представляють загальну команду (на приклад NAVI) у конкретній грі (на приклад команда NAVI в CS2)

`game_team_id` - (IDENTITY) - Ідентифікатор команди по грі **(PK)**
`game_id` - Ідентифікатор гри, позичений з таблиці Game **(FK)**
`team_id` - Ідентифікатор команди, позичений з таблиці Team **(FK)**
`coach_name` — Ім'я та прізвище тренера команди.

#### game_team - team_player (1:N)

У одній команді по грі має бути мінімум один гравець
Гравці знаходяться в команді

#### game_team - match_participant (1:N/0)

Одна команда по грі може бути учасником матчів, а може і не приймати жодної участі
Команда приймає участь у матчах

#### game_team - tournament (1/0:N/0)

Команда по грі як може так і не може бути переможцем кількох або жодного турнірів. В той час як у турніра може ще не бути жодного переможця.
У турніра є переможець

## game:

Таблиця де зберігаються ігри по яких можуть бути організовані турніри

`game_id` - (IDENTITY) - Ідентифікатор гри **(PK)**
`game_name` - (TEXT) - Назва гри **UNIQUE**
`genre` - (game_genre) - Жанр гри

#### game - tournament (1:N/0)

Турнір проводится по одній конкретній грі, але є ігри по яким турніри не проводяться
Гра повинна проводитися по одній, конкретній грі

#### game - game_team (1:N/0)

Команда є прив’язана до гри, але не всі ігри прив’язані до команд
Команда повинна спеціалізуватися лише в одній грі

## tournament:

Таблиця з даними про турніру

`tournamentID` - (IDENTITY) - Ідентифікатор турніру **(PK)**
`organizer_id` - (INT) - Ідентифікатор організатора турніру, позичений з таблиці Organizer **(FK)**
`game_id` - (INT) - Ідентифікатор гри, позичений з таблиці Game **(FK)**
`winner_id` - (INT) - Ідентифіцатор переможця турніру, позичений з таблиці Game team **(FK)**
`prize` - (TEXT) - Приз фонд турніра
`tournament_name` - (TEXT) - Назва турніру
`start_date` - (TIMESTAMPTZ) - Дата початку турніру
`status` - (tournament_status) - Статус турніру, наприклад запланований, у процесі проведення або завершений.

#### tournament - match (1:N/0)

В одному турнірі проводятся декілька матчів. Проте матчі можуть бути ще не запланованими, а отже не існувати.
Матч повинен бути частиною турніру

## organizer:

Таблиця з даними про організатора турніру

`organizer_id` - (IDENTITY) - Ідентифікатор організатора **(PK)**
`organizer_name` - (TEXT) - Ім’я організатора **UNIQUE**

#### organizer - tournament (1:N/0)

У турнірів є організатори, але не всі організатори при реєстрації одразу проводити турнір.
У турніра завжди є організатор

## match:

У цій таблиці зберігається інформація про матчі турніру

`match_id` - (IDENTITY) - Ідентифікатор матчу **(PK)**
`tournament_id` — Ідентифікатор турніру, у рамках якого проводиться матч, позичений з таблиці Tournament **(FK)**
`date` — Дата та час проведення матчу.
`status` — Статус матчу, наприклад запланований, у процесі проведення або завершений.

#### match - match_participant (1:N)

В одному матчі беруть участь кілька команд учасників
У матча хтось повинен приймати участь

## match_participant:

Таблиця у якій збереженні дані про команду у матчі та факт їх участі

`match_participant_id` - (IDENTITY) - Ідентифікатор участі команди в матчі **(PK)**
`match_id` — Ідентифікатор матчу, позичений з таблиці Match **(FK)**
`game_team_id` — Ідентифікатор команди в конкретній грі, позичений з таблиці Game Team **(FK)**
`is_winner` - Булеве значення яке позначає чи перемогла команда у матчі

## team:

Таблиця з інформацією про команду

`team_id` - (IDENTITY) - Ідентифікатор команди **(PK)**
`team_name` - (INT) - Назва кіберспортивної команди. **UNIQUE**
`country` - (ENUM) - Країна, яку представляє команда.

#### team - game_team (1:N/0)

Одна команда може бути розділена між іграми
У загальних команд є склад який представляєїї в певній грі

# Створення таблиці(SQL команди)

## Створення

```SQL
START TRANSACTION;
--Enums
CREATE TYPE country_enum AS ENUM (
  	'USA',
  	'China',
  	'Ukraine',
  	'Sweden',
  	'Brazil',
  	'Other'
);

CREATE TYPE role_enum AS ENUM (
  	'Captain',
  	'Player'
);

CREATE TYPE game_genre AS ENUM (
	'FPS',
	'strategy',
	'RTS',
	'card game',
	'MOBA',
	'other'
);

CREATE TYPE tournament_status AS ENUM (
	'planned',
	'in works',
	'happeninng',
	'done',
	'cancelled'
);

CREATE TYPE match_status AS ENUM (
	'planned',
	'in progress',
	'finished',
	'cancelled'
);





-- Tables
CREATE TABLE game (
	game_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	game_name TEXT NOT NULL,
	genre game_genre DEFAULT 'other' NOT NULL,

	CONSTRAINT uq_game_name UNIQUE (game_name)
);

CREATE TABLE orginizer (
	orginizer_id INT GENERATED ALWAYS AS IDENTITY  PRIMARY KEY,
	orginizer_name TEXT NOT NULL,

	CONSTRAINT uq_orginizer_name UNIQUE (orginizer_name)
);

CREATE TABLE player(
	player_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	nickname TEXT NOT NULL UNIQUE,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
	country country_enum NOT NULL,
	date_of_birth DATE NOT NULL,

	CONSTRAINT uq_nickname UNIQUE (nickname)
);

CREATE TABLE team (
	team_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	team_name TEXT NOT NULL,
	country country_enum NOT NULL,

	CONSTRAINT uq_team_name UNIQUE (team_name)
);

CREATE TABLE game_team(
  	game_team_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  	game_id INT NOT NULL,
  	team_id INT NOT NULL,
  	coach_name TEXT,

	--Game connection
	CONSTRAINT fk_game_id
		FOREIGN KEY (game_id)
		REFERENCES game (game_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	--Team connection
	CONSTRAINT fk_team_id
		FOREIGN KEY (team_id)
		REFERENCES team (team_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

CREATE TABLE team_player(
	team_player_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  	player_id INT NOT NULL,
  	game_team_id INT NOT NULL,
  	join_date DATE NOT NULL,
  	leave_date DATE,
  	team_role role_enum NOT NULL,

	--Player connection
	CONSTRAINT fk_player_id
		FOREIGN KEY (player_id)
		REFERENCES player (player_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	--Game_team connection
	CONSTRAINT fk_game_team_id
		FOREIGN KEY (game_team_id)
		REFERENCES game_team (game_team_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

CREATE TABLE tournament (
	tournament_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	winner_id INT,
	game_id INT NOT NULL,
	orginizer_id INT NOT NULL,
	prize TEXT NOT NULL,
	tournament_name TEXT NOT NULL,
	start_date TIMESTAMPTZ NOT NULL,
	status tournament_status DEFAULT 'planned' NOT NULL,

	--Winner connection
	CONSTRAINT fk_winner
		FOREIGN KEY (winner_id)
		REFERENCES game_team (game_team_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	--Game connection
	CONSTRAINT fk_game
		FOREIGN KEY (game_id)
		REFERENCES game (game_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	--Orginizer connection
	CONSTRAINT fk_orginizer
		FOREIGN KEY (orginizer_id)
		REFERENCES orginizer (orginizer_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

CREATE TABLE game_match (
	game_match_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tournament_id INT NOT NULL,
	status match_status DEFAULT 'planned' NOT NULL,
	match_date TIMESTAMPTZ NOT NULL,

	--Tournament connection
	CONSTRAINT fk_tournament
		FOREIGN KEY (tournament_id)
		REFERENCES tournament (tournament_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE match_participant (
	match_participant_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	game_match_id INT NOT NULL,
	game_team_id INT NOT NULL,
	is_winner BOOLEAN DEFAULT NULL,

	--Game match connection
	CONSTRAINT fk_game_match
		FOREIGN KEY (game_match_id)
		REFERENCES game_match (game_match_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	--Game team connection
	CONSTRAINT fk_game_team
		FOREIGN KEY (game_team_id)
		REFERENCES game_team (game_team_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,

	--Makes sure no team participates twice in one match
	CONSTRAINT uq_match_game_team UNIQUE (game_match_id, game_team_id)
);
COMMIT;
```

## Наповнення

```SQL
INSERT INTO game (game_name, genre) VALUES
  ('CS2', 'FPS'),
  ('DOTA 2', 'MOBA'),
  ('Balatro', 'card game'),
  ('Overwatch 2', 'FPS');

INSERT INTO orginizer (orginizer_name) VALUES
  ('Valve'),
  ('Zaino'),
  ('Blizzard');

INSERT INTO tournament (game_id,orginizer_id,prize,tournament_name,start_date,status) VALUES
  (1, 1, '300$', 'CS2 International', '2026-09-10 13:37:00+03', 'done'),
  (3,2, 'Eveything in this world', 'Major League Balatro', '2026-09-18 13:37:00+03', 'happeninng'),
  (2,1, 'idk', 'Dota 2 International', '2026-10-18 13:37:00+03', 'planned');
UPDATE tournament SET winner_id = 1 WHERE tournament_id = 1;

INSERT INTO player (nickname,first_name,last_name,country,date_of_birth)
VALUES ('s1mple','Oleksandr','Kostyliev','Ukraine'::country_enum,'1997-10-02'),
 ('Notail','Johan','Sundstein','Sweden'::country_enum,'1993-10-08'),
 ('Dendi','Danil','Ishutin','Ukraine'::country_enum,'1989-12-30'),
 ('Profit','Park','Jun-young','China'::country_enum,'1999-01-06');

INSERT INTO team_player (player_id,game_team_id,join_date,team_role)
VALUES (1,1,'2016-01-01','Player'::role_enum),
(2,2,'2012-01-01','Captain'::role_enum),
(3,2,'2011-01-01','Captain'::role_enum),
(4,3,'2017-01-01','Player'::role_enum);

INSERT INTO game_team (game_id,team_id)
VALUES (1,1),
(2,1),
(1,2),
(4,3),
(4,4);

INSERT INTO team (team_name, country) VALUES
  ('Natus Vincere', 'Ukraine'),
  ('OG', 'Sweden'),
  ('Team Secret', 'Other'),
  ('Seoul Dynasty', 'China');


INSERT INTO game_match (tournament_id, status, match_date) VALUES
  (1, 'finished', '2026-09-10 14:00:00+03'),
  (1, 'finished', '2026-09-10 17:30:00+03'),
  (2, 'in progress', '2026-09-18 15:00:00+03'),
  (3, 'planned', '2026-10-18 18:00:00+03');

INSERT INTO match_participant (game_match_id, game_team_id, is_winner) VALUES
  (1, 1, TRUE),
  (1, 2, FALSE),
  (2, 2, TRUE),
  (2, 3, FALSE),
  (3, 3, NULL),
  (3, 4, NULL);
```
