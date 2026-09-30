Типи:
team_status: "active", "disbanded"
team_member_status: "active", "left", "kicked"
tournament_status: "registration", "ongoing", "finished"
tournament_participant_status: "pending", "accepted", "rejected"
encounter_status: "ongoing", "scheduled", "finished"
team_role: "player","captain"

Сутності:

User:
uuid id PK - унікальний ідентифікатор користувача
string email UNIQUE NOT NULL - унікальна електронна пошта
string hashed_password NOT NULL - хешований пароль
string nickname UNIQUE NOT NULL - унікальний нікнейм на платформі
string name NULL - ім'я користувача
string description NULL - опис користувача
string avatar_url NULL - аватар користувача
timestamp created_at NOT NULL DEFAULT now()

Game:
uuid id PK - унікальний ідентифікатор гри
string game_name UNIQUE NOT NULL - назва гри
string logo_url NULL - логотип гри

Game_Account:
uuid user_id FK PK NOT NULL -  ідентифікатор юзера
uuid game_id FK PK NOT NULL -  ідентифікатор гри
string game_account_id UNIQUE NOT NULL -  ідентифікатор акаунта користувача в конкретній грі

Team:
uuid id PK - унікальний ідентифікатор команди
string name UNIQUE NOT NULL - унікальна назва команди
string avatar_url NULL - аватар команди 
timestamp created_at NOT NULL - дата та час створення команди
int max_team_players NULL - максимальна кількість учасників
team_status status NOT NULL DEFAULT "active" - статус команди

Team_Member:
uuid id PK - унікальний ідентифікатор учасника команди
uuid team_id FK NOT NULL - ідентифікатор команди
uuid user_id FK NOT NULL - ідентифікатор користувача (гравця)
timestamp joined_at NOT NULL - дата вступу до команди
timestamp leave_at NULL - дата виходу з команди
team_member_status status NOT NULL DEFAULT "active" - статус учасника команди

Team_Member_Role:
uuid id PK - унікальний ідентифікатор ролі користувача
uuid team_member_id FK  - ідентифікатор учасника команди
team_role role - назва ролі

Tournament:
uuid id PK - унікальний ідентифікатор турніру
uuid game_id FK NOT NULL - ідентифікатор гри
uuid organizer_id FK NOT NULL - ідентифікатор організатора
timestamp created_at NOT NULL DEFAULT now()
timestamp start_at NULL - дата початку
string name NOT NULL - назва турніру
decimal prize_pool NULL - сума призового фонду
string currency NULL - валюта 
int max_teams NULL - максимальна кількість команд
int min_teams NULL - мінімальна кількість команд
int min_team_players NOT NULL - мінімальна кількість гравців у команді для заявки
int max_team_players NULL - максимальна кількість гравців у команді для заявки
tournament_status status NOT NULL DEFAULT "registration"
СHECK(max_teams > min_teams)
CHECK(max_team_players > min_team_players)

Tournament_Application:
uuid tournament_id FK PK NOT NULL - ідентифікатор турніру
uuid team_id FK PK NOT NULL - ідентифікатор команди
tournament_participant_status status NOT NULL DEFAULT "pending" - статус заявки

Tournament_Application_Member:
uuid tournament_id FK PK NOT NULL - ідентифікатор турніра
uuid tournament_application_id FK NOT NULL - ідентифікатор заявки
uuid user_id FK PK NOT NULL - ідентифікатор юзера

Encounter:
uuid id PK - унікальний ідентифікатор зустрічі
uuid tournament_id FK NOT NULL - ідентифікатор турніру
string stage NOT NULL - етап турнірної сітки
uuid tournament_application_id_1 FK NULL - ідентифікатор першої команди
uuid tournament_application_id_2 FK NULL - ідентифікатор другої команди
uuid winner_tournament_application_id FK NULL - ідентифікатор команди-переможця
uuid next_encounter_id FK NULL - ідентифікатор наступної зустрічі в сітці
int max_matches NOT NULL - максимальна кількість матчів зустічі(формат BO3 - 3 матчі максимум)
encounter_status status NOT NULL DEFAULT "scheduled" - статус зустрічі

Match:
uuid id PK - унікальний ідентифікатор матчу
string match_game_id NOT NULL - ідентифікатор матчу в грі
uuid encounter_id FK NOT NULL - ідентифікатор зустрічі
int map_order NOT NULL - порядковий номер матчу в зустрічі
uuid winner_tournament_application_id FK NULL - ідентифікатор команди, що виграла матч
UNIQUE(encounter_id, map_order)

Player_Statistic:
uuid match_id FK PK NOT NULL - ідентифікатор конкретного матчу
uuid user_id FK PK NOT NULL - ідентифікатор гравця
int kills NULL - кількість вбивств
int deaths NULL - кількість смертей
int assists NULL - кількість асистів

Зв'язки:
1)Користувач може мати ігрові акаунти в багатьох іграх, а гра може містити акаунти багатьох користувачів (N:M, реалізовано через сутність Game_Account).
2)Гравець може бути учасником багатьох команд, і команда може містити багатьох учасників (N:M, реалізовано через сутність Team_Member).
3)Учасник команди може мати кілька ролей, але кожен запис ролі належить строго одному учаснику (1:N).
4)Користувач може створити багато турнірів, але турнір має лише одного організатора (1:N).
5)Гра може мати багато турнірів, але кожен турнір проводиться строго з однієї гри (1:N).
6)Команда може подати заявку на багато турнірів, і турнір містить багато команд-учасників (N:M, реалізовано через сутність Tournament_Application).
7)Один користувач може бути зареєстрованим у багатьох заявках на турніри від команди, та одна заявка від команди на турнір може містити багато користувачів(N:M реалізовано через сутність Tournament_Application_Member).
8)Турнір може містити багато Tournament_Application_Member, але кожен Tournament_Application_Member належить лише одному турніру(1:N).
9)Турнір містить багато зустрічей, кожна зустріч належить строго одному турніру (1:N).
10)Заявки-команди може брати участь у багатьох зустрічах, а у зустрічі беруть участь дві заявки-команди заявки (N:M, так як команди завжди дві і одна з них переможець, в сутність зустріч додано три атрибути: айді першої команди, айді другої команди та айді команди переможця).
11)Зустріч має посилання на наступну зустріч у сітці для автоматичного просування переможця (рекурсивний зв'язок 1:N).
12)Зустріч складається з кількох окремих матчів, кожен матч належить строго одній зустрічі (1:N).
13)Кожен матч містить статистику для багатьох гравців, а гравець має статистику в багатьох матчах (N:M, реалізовано через сутність Player_Statistic).
