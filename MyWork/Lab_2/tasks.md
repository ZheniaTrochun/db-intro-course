# Lab 2 — DDL: перетворення ER-діаграми на схему PostgreSQL

## Завдання

На основі концептуальної моделі з Lab 1 (VideoHub) створити фізичну схему БД у PostgreSQL:

1. **CREATE EXTENSION** — підключити `uuid-ossp` для генерації UUID
2. **CREATE TABLE** — створити всі 5 таблиць-сутностей з типами даних, PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, DEFAULT:
   - `User` — email UNIQUE, username UNIQUE, password NULLABLE, google_id UNIQUE NULLABLE
   - `Video` — title NOT NULL, url NOT NULL, views DEFAULT 0, author_id FK → User ON DELETE CASCADE
   - `Comment` — text NOT NULL, user_id FK → User, video_id FK → Video, обидва CASCADE
   - `Like` — user_id FK → User, video_id FK → Video, UNIQUE(user_id, video_id), обидва CASCADE
   - `Subscription` — subscriber_id FK → User, channel_id FK → User, UNIQUE(subscriber_id, channel_id), CHECK(subscriber_id ≠ channel_id), обидва CASCADE

3. **INSERT** — заповнити всі таблиці тестовими даними (мінімум 3-5 рядків на таблицю):
   - 5 користувачів
   - 5 відео
   - 5 коментарів
   - 5 лайків
   - 5 підписок

## Порядок створення таблиць

Спочатку батьківські (без FK), потім дочірні (з FK):
1. User (без FK)
2. Video (FK → User)
3. Comment (FK → User, Video)
4. Like (FK → User, Video)
5. Subscription (FK → User, User)

## Порядок INSERT

Спочатку батьківські записи, потім дочірні:
1. User
2. Video (author_id посилається на User)
3. Comment (user_id, video_id посилаються на User, Video)
4. Like (user_id, video_id)
5. Subscription (subscriber_id, channel_id)
