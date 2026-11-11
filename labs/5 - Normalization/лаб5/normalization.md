# Лаба 5

## Функціональні залежності минулої схеми:

### Game:

- game_id -> game_name
- game_id -> genre

### Tournament:

- tournament_id -> winner_id
- tournament_id -> game_id
- tournament_id -> orginizer_id
- tournament_id -> prize
- tournament_id -> tournament_name
- tournament_id -> start_date
- tournament_id -> status

### Orginizer:

- orginizer_id -> orginizer_name

### Player:

- player_id -> nickname
- player_id -> first_name
- player_id -> last_name
- player_id -> country
- player_id -> date_of_birth

### Team Player:

- (player_id, game_team_id, join_date) -> team_player_id
- team_player_id -> leave_date
- team_player_id -> role

### Game Team:

- game_team_id -> game_id
- game_team_id -> team_id
- game_team_id -> coach_name

### Team:

- team_id → team_name
- team_id → country

### Match:

- match_id → tournament_id
- match_id → status
- match_id → date

### Match_participant:

- (match_id, game_team_id) → is_winner

---

## Нормалізація схеми:

### Початкова форма

До роботи, не була в жодній нормальній формі, оскільки поле prize у tournament не було атомарним.

### 1NF:

Перша нормальна форма вимагає наступних обмежень:

1. Усі атрибути містять лише атомарні (неподільні) значення
2. Відсутні повторювані групи атрибутів
3. Кожен запис унікальний
4. Порядок записів не важливий

#### Наші неспівпадіння:

- **Призи турніру можуть бути не тільки для першого місця, а отже бути не атомарними.**
      **Виправлення:** - Створеня окрему таблицю (prize) призу для окремого місця для турніру - Через те що цю роьл на себе забрала нова таблиця, поле prize було прибране з таблиці tournament - Разом з цим стало зрозуміло, що немає способі визначити яке місце зайняла команда, через що додали асоціативну таблицю tournament_participation - Через те що цю роьл на себе забрала нова таблиця, поле winner_id було прибране з таблиці tournament

Команда для зміни таблиць

```SQL
ALTER TABLE tournament
	DROP CONSTRAINT fk_winner,
	DROP COLUMN winner_id,
	DROP COLUMN prize;

CREATE TABLE prize(
	tournament_id INT NOT NULL,
	place INT NOT NULL,
	prize TEXT NOT NULL,

	CONSTRAINT pk
	PRIMARY KEY (tournament_id, place),

	CONSTRAINT fk_tournament_id
	FOREIGN KEY (tournament_id)
		REFERENCES tournament (tournament_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT positive_place CHECK (place > 0)
);

CREATE TABLE tournament_participation(
	game_team_id INT,
	tournament_id INT,
	place INT,

	CONSTRAINT pk_tournament_participation
	PRIMARY KEY (tournament_id, place),

	CONSTRAINT fk_tournament_id
	FOREIGN KEY (tournament_id)
		REFERENCES tournament (tournament_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT fk_game_team_id
	FOREIGN KEY (game_team_id)
		REFERENCES game_team (game_team_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
)
```

### 2NF:

Друга нормальна форма вимагає:

1. Перша нормальна форма
2. Кожен неключовий атрибут повністю функціонально залежить від первинного ключа (немає часткових залежностей)

У нас не було подібних проблем і після минулого пункту таблиця вже була в 2NF, тому ніяких виправлень також не було.

### 3NF:

Третя нормальна форма вимагає:

1. Друга нормальна форма
2. Відсутні транзитивні залежності неключових атрибутів від первинного ключа

#### Наші неспівпадіння:

- **В team_player team_player_id насправді не був потнрібен.**
      **Виправлення:** - Ми прибрали поле team_player_id зробивши композитний первинний ключ (player_id, game_team_id, join_date), оскільки team_player_id мав транзитивну залежність від вищезгаданих трьох, а решта полів залежали від team_player_id

Команда для зміни таблиць

```SQL
ALTER TABLE team_player
	DROP CONSTRAINT team_player_pkey,
	ADD CONSTRAINT pk_team_player PRIMARY KEY (player_id, game_team_id, join_date),
	DROP COLUMN team_player_id;
```

---

# Нова схема

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

`player_id` - (INT) - Ідентифікатор гравця, позичений з таблиці Players **(PK)** **(FK)**
`game_team_id` - (INT) - Ідентифікатор команди по грі, позичений з таблиці Game Team **(PK)** **(FK)**
`join_date` - (DATE) - Дата приєднання до команди **(PK)**
`leave_date` - (DATE) - Дата виходу з команди (якщо був)
`role` - (role_enum) - Роль у команді

## game_team:

У цій таблиці зберігаються команди які представляють загальну команду (на приклад NAVI) у конкретній грі (на приклад команда NAVI в CS2)

`game_team_id` - (IDENTITY) - Ідентифікатор команди по грі **(PK)**
`game_id` - (INT) - Ідентифікатор гри, позичений з таблиці Game **(FK)**
`team_id` - (INT) - Ідентифікатор команди, позичений з таблиці Team **(FK)**
`coach_name` — (TEXT) - Ім'я та прізвище тренера команди.

#### game_team - team_player (1:N)

У одній команді по грі має бути мінімум один гравець
Гравці знаходяться в команді

#### game_team - match_participant (1:N/0)

Одна команда по грі може бути учасником матчів, а може і не приймати жодної участі
Команда приймає участь у матчах

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
`tournament_name` - (TEXT) - Назва турніру
`start_date` - (TIMESTAMPTZ) - Дата початку турніру
`status` - (tournament_status) - Статус турніру, наприклад запланований, у процесі проведення або завершений.

#### tournament - game_match (1:N/0)

В одному турнірі проводятся декілька матчів. Проте матчі можуть бути ще не запланованими, а отже не існувати.
Матч повинен бути частиною турніру

## organizer:

Таблиця з даними про організатора турніру

`organizer_id` - (IDENTITY) - Ідентифікатор організатора **(PK)**
`organizer_name` - (TEXT) - Ім’я організатора **UNIQUE**

#### organizer - tournament (1:N/0)

У турнірів є організатори, але не всі організатори при реєстрації одразу проводити турнір.
У турніра завжди є організатор

## game_match:

У цій таблиці зберігається інформація про матчі турніру

`match_id` - (IDENTITY) - Ідентифікатор матчу **(PK)**
`tournament_id` - (INT) - Ідентифікатор турніру, у рамках якого проводиться матч, позичений з таблиці Tournament **(FK)**
`status` - (match_status) - Статус матчу, наприклад запланований, у процесі проведення або завершений.
`date` - (TIMESTAMPTZ) - Дата та час проведення матчу.

#### game_match - match_participant (1:N)

В одному матчі беруть участь кілька команд учасників
У матча хтось повинен приймати участь

## match_participant:

Таблиця у якій збереженні дані про команду у матчі та факт їх участі

`match_id` - (INT) - Ідентифікатор матчу, позичений з таблиці Match **(PK)** **(FK)**
`game_team_id` - (INT) - Ідентифікатор команди в конкретній грі, позичений з таблиці Game Team **(PK)** **(FK)**
`is_winner` - (BOOL) - Булеве значення яке позначає чи перемогла команда у матчі

## team:

Таблиця з інформацією про команду

`team_id` - (IDENTITY) - Ідентифікатор команди **(PK)**
`team_name` - (INT) - Назва кіберспортивної команди. **UNIQUE**
`country` - (country_enum) - Країна, яку представляє команда.

#### team - game_team (1:N/0)

Одна команда може бути розділена між іграми
У загальних команд є склад який представляєїї в певній грі

## prize:

Таблиця з призами для певних місць для певного турніру

`tournament_id` - (INT) - Ідентифікатор турніру **(PK)** **(FK)**
`place` - (INT) - Місця для якого цей приз **(PK)** **>0**
`prize` - (TEXT) - Опис призу

#### prize - tournament (N/0:1)

У турніра може бути багато призів, або не бути взагалі
У турнірів є призовий фонд

## tournament_participation:

Факт участі команди в турнірі

`game_team_id` - (INT) - Ідентифікатор команди **(PK)** **(FK)**
`tournament_id` - (INT) - Ідентифікатор турніру **(PK)** **(FK)**
`place` - (INT) - Місця команди **>0**

#### tournament_participation - tournament (N/0:1)

В турнірі може бути багато учасників, але учасник повинен мати турнір
Факт участі в турнірі

#### tournament_participation - game_team (N/0:1)

Команда може приймати багато участей, але участь лише у одної команди
Факт участі команди

# Створення таблиці(SQL команди)

## Створення

```SQL
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
  	player_id INT NOT NULL,
  	game_team_id INT NOT NULL,
  	join_date DATE NOT NULL,
  	leave_date DATE,
  	team_role role_enum NOT NULL,

	CONSTRAINT pk_team_player
	PRIMARY KEY (player_id, game_team_id, join_date),

    CONSTRAINT chk_leave_time_after_join CHECK (leave_date>=join_date),
	CONSTRAINT uq_no_double_participation UNIQUE NULLS NOT DISTINCT (player_id, game_team_id, leave_date),
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
	game_id INT NOT NULL,
	orginizer_id INT NOT NULL,
	tournament_name TEXT NOT NULL,
	start_date TIMESTAMPTZ NOT NULL,
	status tournament_status DEFAULT 'planned' NOT NULL,

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
	game_match_id INT NOT NULL,
	game_team_id INT NOT NULL,
	is_winner BOOLEAN DEFAULT NULL,

	--Primary key
	CONSTRAINT pk_game_match_game_team
		PRIMARY KEY (game_match_id, game_team_id),
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

CREATE TABLE prize(
	tournament_id INT NOT NULL,
	place INT NOT NULL,
	prize TEXT NOT NULL,

	CONSTRAINT pk
	PRIMARY KEY (tournament_id, place),

	CONSTRAINT fk_tournament_id
	FOREIGN KEY (tournament_id)
		REFERENCES tournament (tournament_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT positive_place CHECK (place > 0)
);

CREATE TABLE tournament_participation(
	game_team_id INT,
	tournament_id INT,
	place INT,

	CONSTRAINT pk_tournament_participation
	PRIMARY KEY (tournament_id, place),

	CONSTRAINT fk_tournament_id
	FOREIGN KEY (tournament_id)
		REFERENCES tournament (tournament_id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	CONSTRAINT fk_game_team_id
	FOREIGN KEY (game_team_id)
		REFERENCES game_team (game_team_id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);
```
