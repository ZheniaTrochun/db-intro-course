# users by @ApostolQleg

## ❇️ Create table
*Мета*: створити таблицю `users` для зберігання даних користувачів, а також типи `user_status_enum` та `user_role_enum`.
*Очікуваний результат*: типи `user_status_enum`, `user_role_enum`, таблиця `users` та індекс `idx_user_status` будуть створені в базі даних.
*Результат*: успішне виконання запитів `CREATE TYPE`, `CREATE TABLE` та `CREATE INDEX`.

```SQL
CREATE TYPE user_status_enum AS ENUM('active', 'banned', 'deactivated');
CREATE TYPE user_role_enum AS ENUM('user', 'admin');

CREATE TABLE users(
    user_id UUID PRIMARY KEY DEFAULT uuidv7(),
    nickname VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    google_id TEXT UNIQUE,
    bio TEXT NOT NULL DEFAULT '',
    password_hash TEXT,
    avatar_url TEXT,
    social_networks TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    max_streak INT NOT NULL DEFAULT 0 CHECK(max_streak >= 0),
    timezone TEXT NOT NULL DEFAULT 'UTC',
    streak_start_date DATE,
    last_watch_date DATE,
    profile_frame_url TEXT,
    profile_background_url TEXT,
    user_role user_role_enum NOT NULL DEFAULT 'user',
    user_status user_status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT check_user_auth_method CHECK(password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX idx_user_status ON users(user_status);
```


## 🗑 Drop table
*Мета*: видалити таблицю `users` та типи `user_role_enum` і `user_status_enum`, якщо вони існують.
*Очікуваний результат*: таблиця `users` та обидва типи будуть видалені з бази даних, якщо вони існують (зовнішні ключі інших таблиць на `users` буде видалено завдяки `CASCADE`).
*Результат*: успішне виконання запитів `DROP TABLE` та `DROP TYPE`, якщо вони існували.

```SQL
BEGIN;
  DROP TABLE IF EXISTS users CASCADE;
  DROP TYPE IF EXISTS user_role_enum;
  DROP TYPE IF EXISTS user_status_enum;
COMMIT;
```


## ✨ Insert queries

### IDs

- `11111111-1111-4111-8111-111111111111`
- `67676767-6767-6767-6767-676767676767`
- `14881488-1488-1488-1488-148814881488`

### All colums
*Мета*: заповнити таблицю `users` детермінованими записами, вказавши значення для всіх полів.
*Очікуваний результат*: у таблицю `users` будуть додані 3 користувачі з вказаними ідентифікаторами, ролями та статусами.
*Результат*: успішне виконання запиту `INSERT` та додавання 3 нових записів до таблиці.

```SQL
INSERT INTO users(user_id, nickname, full_name, email, google_id, bio, password_hash,
    avatar_url, social_networks, max_streak, timezone, streak_start_date, last_watch_date, profile_frame_url,
    profile_background_url, user_role, user_status, created_at, updated_at
) VALUES 
    ('11111111-1111-4111-8111-111111111111', 'ApostolQleg', 'Oleg Bondarenko', 'oleg0@email.example', 
    '104566789012345678901', 'my name is Oleg', 'cool hashed password', 'https://avatar-url', 
    ARRAY['https://t.me/oleg', 'https://github.com/ApostolQleg'], 120, 'Europe/Kyiv', 
    '2026-08-05', '2026-10-05', 'https://frame-url', 'https://background-url', 'user', 'active', 
    '2026-10-05 16:30:00Z', '2026-10-05 16:30:00Z'),
    ('67676767-6767-6767-6767-676767676767', 'dadencukillia', 'Illia Diadenchuk', 'illia1@email.example', 
    '117492058372950481729', 'my name is Illia', 'cool hashed password', 'https://avatar-url', 
    ARRAY['https://t.me/illia', 'https://github.com/dadencukillia'], 100, 'Asia/Tokyo', 
    '2001-08-05', '2001-09-11', 'https://frame-url', 'https://background-url', 'admin', 'banned', 
    '2000-10-05 16:30:00Z', '2000-10-05 16:30:00Z'),
    ('14881488-1488-1488-1488-148814881488', 'XxMariavxX', 'Maria Synevych', 'maria2@email.example', 
    '109483726154958372610', 'my name is Maria', 'cool hashed password', 'https://avatar-url', 
    ARRAY['https://t.me/XxMariavxX', 'https://github.com/XxMariavxX'], 30, 'America/New_York', 
    '2016-08-05', '2016-10-05', 'https://frame-url', 'https://background-url', 'user', 'deactivated', 
    '2016-10-05 16:30:00Z', '2016-10-05 16:30:00Z');
```

### Mandatory only colums
*Мета*: додати нових користувачів, вказавши лише обов'язкові поля (нікнейм, повне ім'я, email та `google_id`).
*Очікуваний результат*: у таблицю `users` будуть додані 3 користувачі, а ідентифікатор (`uuidv7()`), роль (`user`), статус (`active`), часовий пояс (`UTC`) та дати створення встановляться автоматично.
*Результат*: успішне виконання запиту `INSERT` та додавання 3 нових записів до таблиці (запит слід виконувати на порожній таблиці через унікальні поля).

```SQL
INSERT INTO users(nickname, full_name, email, google_id) VALUES 
    ('ApostolQleg', 'Oleg Bondarenko', 'oleg0@email.example', '104566789012345678901'),
    ('dadencukillia', 'Illia Diadenchuk', 'illia1@email.example', '117492058372950481729'),
    ('XxMariavxX', 'Maria Synevych', 'maria2@email.example', '109483726154958372610');
```

### With returning part (`RETURNING`)
*Мета*: зареєструвати нового користувача та отримати повернені дані для відображення в UI.
*Очікуваний результат*: новий користувач буде доданий до таблиці `users`, а також будуть повернуті його ідентифікатор, нікнейм, email, статус та дата створення.
*Результат*: успішне виконання запиту `INSERT` з частиною `RETURNING`.

```SQL
INSERT INTO users(nickname, full_name, email, google_id)
VALUES ('newbie_user', 'Petro Poroshenko', 'petro3@email.example', '100000000000000000003')
RETURNING user_id, nickname, email, user_status, created_at;
```

### Some interesting examples

*Мета*: зареєструвати користувача за допомогою пароля (без `google_id`), вказавши часовий пояс та соціальні мережі.
*Очікуваний результат*: новий користувач із хешем пароля буде доданий до таблиці, а також будуть повернуті його ідентифікатор, нікнейм та часовий пояс.
*Результат*: успішне виконання запиту `INSERT` з частиною `RETURNING` (обмеження `check_user_auth_method` виконується завдяки `password_hash`).

```SQL
INSERT INTO users(nickname, full_name, email, password_hash, timezone, social_networks)
VALUES (
    'password_user',
    'Ivan Ivanenko',
    'ivan4@email.example',
    'the best hashed password',
    'Europe/Kyiv',
    ARRAY['https://t.me/ivan']
)
RETURNING user_id, nickname, timezone;
```

*Мета*: прив'язати Google-акаунт до наявного користувача під час входу через Google, або створити нового, якщо користувача з таким email немає (`UPSERT`).
*Очікуваний результат*: якщо email уже існує, оновиться лише порожній `google_id` та `updated_at`; якщо ні - буде створено нового користувача. У обох випадках повертаються дані запису.
*Результат*: успішне виконання запиту `INSERT` з частинами `ON CONFLICT` та `RETURNING`.

```SQL
INSERT INTO users(nickname, full_name, email, google_id)
VALUES ('google_user', 'Oleg Bondarenko', 'oleg0@email.example', '104566789012345678901')
ON CONFLICT (email) DO 
UPDATE 
    SET 
    google_id = COALESCE(users.google_id, EXCLUDED.google_id),
    updated_at = now()
RETURNING user_id, nickname, google_id, updated_at;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
*Мета*: отримати всі записи з таблиці `users`.
*Очікуваний результат*: всі записи з таблиці `users` з усіма полями (включно з приватними) будуть повернуті.
*Результат*: успішне виконання запиту `SELECT` та повернення всіх записів.

```SQL
SELECT * FROM users;
```

### Select public only info (no `WHERE`, specified fields)
*Мета*: отримати всіх користувачів лише з публічними полями та обчисленою поточним стріком (`current_streak`).
*Очікуваний результат*: будуть повернуті всі записи без приватних даних (email, `google_id`, хеш пароля, часовий пояс), а `current_streak` дорівнюватиме `0`, якщо користувач не дивився аніме більше ніж 1 день, з урахуванням його часового поясу.
*Результат*: успішне виконання запиту `SELECT` з використанням `CASE`.

```SQL
SELECT 
    user_id, 
    nickname, 
    full_name, 
    bio,
    avatar_url, 
    social_networks, 
    max_streak,
    profile_frame_url,
    profile_background_url, 
    user_role, 
    user_status,
    created_at,
    CASE 
        WHEN last_watch_date IS NULL OR streak_start_date IS NULL THEN 0
        WHEN (now() AT TIME ZONE timezone)::date - last_watch_date <= 1 THEN (last_watch_date - streak_start_date + 1)
        ELSE 0
    END AS current_streak
FROM users;
```

### API production example
*Мета*: отримати всі публічні дані одного конкретного користувача за його `user_id` для відображення профілю в UI.
*Очікуваний результат*: повертається один запис користувача `11111111-1111-4111-8111-111111111111` з публічними полями та обчисленим поточним стріком.
*Результат*: успішне виконання запиту `SELECT` з використанням `WHERE` та `CASE`.

`GET /api/user/11111111-1111-4111-8111-111111111111`
```SQL
SELECT 
    user_id, 
    nickname, 
    full_name, 
    bio,
    avatar_url, 
    social_networks, 
    max_streak,
    profile_frame_url,
    profile_background_url, 
    user_role, 
    user_status,
    created_at,
    CASE 
        WHEN last_watch_date IS NULL OR streak_start_date IS NULL THEN 0
        WHEN (now() AT TIME ZONE timezone)::date - last_watch_date <= 1 THEN (last_watch_date - streak_start_date + 1)
        ELSE 0
    END AS current_streak
FROM users
WHERE user_id = '11111111-1111-4111-8111-111111111111';
```

### Some interesting examples

- [x] ORDER BY
- [x] LIMIT
- [x] OFFSET
- [x] JOIN (variations)

*Мета*: отримати рейтинг активних користувачів за найдовшим стріком.
*Очікуваний результат*: повертається список із максимум 10 користувачів зі статусом `active`, відсортований за `max_streak` у спадаючому порядку, а за однакових значень - за нікнеймом.
*Результат*: успішне виконання запиту `SELECT` з використанням `WHERE`, `ORDER BY`, `LIMIT` та `OFFSET`.

```SQL
SELECT
    user_id,
    nickname,
    avatar_url,
    max_streak
FROM users
WHERE user_status = 'active'
ORDER BY max_streak DESC, nickname ASC
LIMIT 10 
OFFSET 10 * 0;
```

*Мета*: отримати 5 користувачів з найбільшою кількістю завершених аніме у списку.
*Очікуваний результат*: повертається список із максимум 5 користувачів з кількістю аніме зі статусом `finished`, відсортований за цією кількістю у спадаючому порядку.
*Результат*: успішне виконання запиту `SELECT` з використанням `LEFT JOIN`, `GROUP BY`, `ORDER BY`, `LIMIT` та `OFFSET`.

```SQL
SELECT
    users.nickname,
    COUNT(list_unit.anime_id) AS finished_count
FROM users
LEFT JOIN anime_list_units list_unit
    ON users.user_id = list_unit.user_id
    AND list_unit.list_unit_status = 'finished'
GROUP BY users.user_id, users.nickname
ORDER BY finished_count DESC, users.nickname ASC
LIMIT 5 
OFFSET 5 * 0;
```


## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: оновити всю публічну інформацію профілю користувача (нікнейм, повне ім'я, біографію, аватар, рамку, фон та список соціальних мереж).
*Очікуваний результат*: у користувача `11111111-1111-4111-8111-111111111111` будуть змінені всі зазначені публічні поля, а поле `updated_at` отримає поточний час.
*Результат*: успішне виконання запиту `UPDATE`.

```SQL
UPDATE users
SET nickname = 'newApostolQleg',
    full_name = 'New Full Name',
    bio = 'Updated bio and full public profile',
    avatar_url = 'https://new-avatar-url',
    profile_frame_url = 'https://new-frame-url',
    profile_background_url = 'https://new-background-url',
    social_networks = ARRAY['https://t.me/new_oleg', 'https://github.com/new_oleg'],
    updated_at = now()
WHERE user_id = '11111111-1111-4111-8111-111111111111';
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: оновити всю публічну інформацію профілю користувача та повернути оновлені значення.
*Очікуваний результат*: у користувача `11111111-1111-4111-8111-111111111111` будуть змінені всі зазначені публічні поля, а також будуть повернуті `user_id`, `nickname`, `bio`, `avatar_url` та `updated_at`. Поле `updated_at` отримає поточний час.
*Результат*: успішне виконання запиту `UPDATE` з частиною `RETURNING`.

```SQL
UPDATE users
SET nickname = 'newApostolQleg',
    full_name = 'New Full Name',
    bio = 'Updated bio and full public profile',
    avatar_url = 'https://new-avatar-url',
    profile_frame_url = 'https://new-frame-url',
    profile_background_url = 'https://new-background-url',
    social_networks = ARRAY['https://t.me/new_oleg', 'https://github.com/new_oleg'],
    updated_at = now()
WHERE user_id = '11111111-1111-4111-8111-111111111111'
RETURNING user_id, nickname, bio, avatar_url, updated_at;
```

### Some interesting examples

*Мета*: заблокувати користувача, не допускаючи блокування адміністраторів.
*Очікуваний результат*: якщо користувач `11111111-1111-4111-8111-111111111111` не є адміністратором, його статус зміниться на `banned`, а також будуть повернуті оновлені дані; для адміністратора не буде змінено жодного запису.
*Результат*: успішне виконання запиту `UPDATE` з умовою за роллю та частиною `RETURNING`.

```SQL
UPDATE users
SET user_status = 'banned',
    updated_at = now()
WHERE user_id = '11111111-1111-4111-8111-111111111111'
    AND user_role <> 'admin'
RETURNING user_id, nickname, user_status, updated_at;
```

*Мета*: зарахувати користувачеві перегляд за сьогодні з урахуванням його часового поясу: продовжити стрік, якщо останній перегляд був учора чи сьогодні, або почати новий, якщо перерва більша за 1 день, а також оновити рекордний стрік `max_streak`.
*Очікуваний результат*: у користувача `11111111-1111-4111-8111-111111111111` оновляться `streak_start_date`, `last_watch_date` та `max_streak`, а також будуть повернуті нові значення.
*Результат*: успішне виконання запиту `UPDATE` з використанням `RETURNING`.

```SQL
UPDATE users
SET streak_start_date = CASE
        WHEN last_watch_date IS NULL
            OR streak_start_date IS NULL
            OR (now() AT TIME ZONE timezone)::date - last_watch_date > 1
        THEN (now() AT TIME ZONE timezone)::date
        ELSE streak_start_date
    END,
    max_streak = GREATEST(
        max_streak,
        CASE
            WHEN last_watch_date IS NULL
                OR streak_start_date IS NULL
                OR (now() AT TIME ZONE timezone)::date - last_watch_date > 1
            THEN 1
            ELSE (now() AT TIME ZONE timezone)::date - streak_start_date + 1
        END
    ),
    last_watch_date = (now() AT TIME ZONE timezone)::date,
    updated_at = now()
WHERE user_id = '11111111-1111-4111-8111-111111111111'
RETURNING user_id, streak_start_date, last_watch_date, max_streak;
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
*Мета*: видалити всіх користувачів з таблиці `users`.
*Очікуваний результат*: всі записи з таблиці `users` будуть видалені, а пов'язані записи (сесії, коментарі) видаляться каскадно.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
BEGIN;
    DELETE FROM users;
COMMIT;
```

### Delete with filter (`WHERE`)
*Мета*: видалити конкретного користувача за його `user_id`.
*Очікуваний результат*: користувач `11111111-1111-4111-8111-111111111111` буде видалений з таблиці разом з пов'язаними записами.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM users
WHERE user_id = '11111111-1111-4111-8111-111111111111';
```

### Delete and return (`WHERE`, `RETURNING`)
*Мета*: видалити конкретного користувача та повернути видалені дані.
*Очікуваний результат*: користувач `11111111-1111-4111-8111-111111111111` буде видалений, а також будуть повернуті його `user_id`, `nickname`, `email` та `user_status`.
*Результат*: успішне виконання запиту `DELETE` з частиною `RETURNING`.

```SQL
DELETE FROM users
WHERE user_id = '11111111-1111-4111-8111-111111111111'
RETURNING user_id, nickname, email, user_status;
```

### Some interesting examples

*Мета*: видалити акаунти, які були деактивовані більше ніж рік тому, та повернути їхні дані.
*Очікуваний результат*: усі користувачі зі статусом `deactivated`, чиє `updated_at` старше 1 року, будуть видалені, а також будуть повернуті `user_id`, `nickname` та `updated_at`.
*Результат*: успішне виконання запиту `DELETE` з частиною `RETURNING`.

```SQL
DELETE FROM users
WHERE user_status = 'deactivated'
    AND updated_at < now() - INTERVAL '1 year'
RETURNING user_id, nickname, updated_at;
```

*Мета*: видалити неактивні акаунти, які зареєструвалися понад 30 днів тому, ніколи нічого не переглядали та не мають жодної сесії.
*Очікуваний результат*: будуть видалені користувачі без сесій з порожнім `last_watch_date`, створені більше 30 днів тому, а також будуть повернуті їхні `user_id`, `nickname` та `created_at`.
*Результат*: успішне виконання запиту `DELETE` з використанням підзапиту `NOT EXISTS` та частини `RETURNING`.

```SQL
DELETE FROM users
WHERE users.last_watch_date IS NULL
    AND users.created_at < now() - INTERVAL '30 days'
    AND NOT EXISTS (
        SELECT 1 FROM sessions WHERE sessions.user_id = users.user_id
    )
RETURNING users.user_id, users.nickname, users.created_at;
```
