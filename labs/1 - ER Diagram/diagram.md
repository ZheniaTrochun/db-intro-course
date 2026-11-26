erDiagram
  User ||--o{ Game_Account : "має"
  Game ||--o{ Game_Account : "має"
  User ||--o{ Team_Member : "є"
  Team ||--o{ Team_Member : "містить"
  Team_Member ||--o{ Team_Member_Role : "має"
  Game ||--o{ Tournament : "проводиться"
  User ||--o{ Tournament : "організовує"
  Tournament ||--o{ Tournament_Application : "отримує"
  Team ||--o{ Tournament_Application : "подає"
  Tournament_Application ||--o{ Tournament_Application_Member : "містить"
  User ||--o{ Tournament_Application_Member : "заявлений у"
  Tournament ||--o{ Encounter : "містить"
  Tournament_Application |o--o{ Encounter : "команда 1"
  Tournament_Application |o--o{ Encounter : "команда 2"
  Tournament_Application |o--o{ Encounter : "переможець"
  Encounter |o--o{ Encounter : "наступна"
  Encounter ||--o{ Match : "складається з"
  Encounter |o--o{ Encounter_Participant : "містить"
  Tournament_Application |o--o{ Match : "переможець"
  Match ||--o{ Player_Statistic : "містить"
  User ||--o{ Player_Statistic : "має"

  User {
    uuid id PK
    string email UK
    string hashed_password
    string nickname UK
    string name
    string description
    string avatar_url
    timestamp created_at
  }
  Game {
    uuid id PK
    string game_name UK
    string logo_url
  }
  Game_Account {
    uuid user_id PK, FK
    uuid game_id PK, FK
    string game_account_id
  }
  Team {
    uuid id PK
    string name UK
    string avatar_url
    timestamp created_at
    int max_team_players
    team_status status
  }
  Team_Member {
    uuid id PK
    uuid team_id FK
    uuid user_id FK
    timestamp joined_at
    team_member_status status
  }
  Team_Member_Role {
    uuid id PK
    uuid team_member_id FK
    team_role role
  }
  Tournament {
    uuid id PK
    uuid game_id FK
    uuid organizer_id FK
    timestamp created_at
    timestamp start_at
    string name
    decimal prize_pool
    string currency
    int max_teams
    int min_teams
    int min_team_players
    int max_team_players
    tournament_status status
  }
  Tournament_Application {
    uuid id PK
    uuid tournament_id FK
    uuid team_id FK
    tournament_participant_status status
  }
  Tournament_Application_Member {
    uuid tournament_application_id PK, FK
    uuid user_id PK, FK
  }
  Encounter {
    uuid id PK
    uuid tournament_id FK
    string stage
    uuid winner_tournament_application_id FK
    uuid next_encounter_id FK
    encounter_status status
  }
  Encounter_Participant {
    uuid encounter_id PK, FK
    uuid tournament_application_id PK, FK
    bool isWinner
  }
  Match {
    uuid id PK
    string match_game_id
    uuid encounter_id FK
    int map_order
    uuid winner_tournament_application_id FK
  }
  Player_Statistic {
    uuid match_id PK, FK
    uuid user_id PK, FK
    int kills
    int deaths
    int assists
  }