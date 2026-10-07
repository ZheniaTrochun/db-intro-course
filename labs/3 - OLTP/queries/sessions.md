# sessions by @ApostolQleg

## ❇️ Create table
*Мета*: створити таблицю `sessions` для зберігання сесій користувачів (refresh-токени та інформація про пристрої) та індекс для швидкого пошуку сесій користувача.
*Очікуваний результат*: таблиця `sessions` та індекс `idx_sessions_user_id` будуть створені в базі даних.
*Результат*: успішне виконання запитів `CREATE TABLE` та `CREATE INDEX`.

```SQL
CREATE TABLE IF NOT EXISTS public.sessions(
    session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    refresh_token BYTEA NOT NULL UNIQUE CHECK(length(refresh_token) = 96),
    expire_time TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '1 year',
    device_type TEXT,
    device_name TEXT,
    os TEXT,
    browser TEXT,
    user_agent TEXT,
    user_location TEXT,
    ip_address INET
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON public.sessions(user_id);
```


## 🗑 Drop table
*Мета*: видалити таблицю `sessions`, якщо вона існує.
*Очікуваний результат*: таблиця `sessions` разом з індексом `idx_sessions_user_id` буде видалена з бази даних, якщо вона існує.
*Результат*: успішне виконання запиту `DROP TABLE`.

```SQL
DROP TABLE IF EXISTS public.sessions;
```


## ✨ Insert queries

### All colums
*Мета*: додати нові сесії до таблиці `sessions`, вказавши значення для всіх полів.
*Очікуваний результат*: у таблицю `sessions` будуть додані 3 сесії з інформацією про пристрої та місцезнаходження користувачів (session_id `1`, `2`, `3`).
*Результат*: успішне виконання запиту `INSERT` та додавання 3 нових сесій до таблиці.

```SQL
INSERT INTO public.sessions(
    user_id, refresh_token, 
    expire_time, device_type, 
    device_name, os,
    browser, user_agent,
    user_location, ip_address
) VALUES
    ('11111111-1111-4111-8111-111111111111', repeat('a', 96)::bytea, 
    now() + INTERVAL '1 year', 'Desktop', 'Asus Vivobook', 'Windows 11', 
    'Firefox', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0)', 
    'Kyiv, Ukraine', '192.168.1.10'),
    ('67676767-6767-6767-6767-676767676767', repeat('b', 96)::bytea, 
    now() + INTERVAL '6 months', 'Mobile', 'iPhone 15', 'iOS 18', 
    'Safari', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)', 
    'Tokyo, Japan', '192.168.1.20'),
    ('14881488-1488-1488-1488-148814881488', repeat('c', 96)::bytea, 
    now() + INTERVAL '1 day', 'Desktop', 'MacBook Pro', 'macOS Sonoma', 
    'Chrome', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)', 
    'New York, USA', '192.168.1.30');
```

### Mandatory only colums
*Мета*: додати нові сесії, вказавши лише обов'язкові поля (користувач та refresh-токен).
*Очікуваний результат*: у таблицю `sessions` будуть додані 3 сесії, а термін дії (1 рік) встановиться автоматично; інформація про пристрій залишиться порожньою (`NULL`).
*Результат*: успішне виконання запиту `INSERT` та додавання 3 нових сесій до таблиці.

```SQL
INSERT INTO public.sessions(user_id, refresh_token) VALUES
    ('11111111-1111-4111-8111-111111111111', repeat('d', 96)::bytea),
    ('67676767-6767-6767-6767-676767676767', repeat('e', 96)::bytea),
    ('14881488-1488-1488-1488-148814881488', repeat('f', 96)::bytea);
```

### With returning part (`RETURNING`)
*Мета*: створити нову сесію під час входу користувача та отримати повернені дані.
*Очікуваний результат*: нова сесія буде додана до таблиці `sessions`, а також будуть повернуті її ідентифікатор, користувач та термін дії.
*Результат*: успішне виконання запиту `INSERT` з частиною `RETURNING`.

```SQL
INSERT INTO public.sessions(user_id, refresh_token, device_type, device_name, ip_address) VALUES
    ('11111111-1111-4111-8111-111111111111', repeat('g', 96)::bytea, 'Mobile', 'Pixel 8', '192.168.1.40')
RETURNING session_id, user_id, expire_time;
```

### Some interesting examples

*Мета*: створити сесію лише для користувача зі статусом `active`, отримавши `user_id` за нікнеймом за допомогою підзапиту.
*Очікуваний результат*: якщо користувач `ApostolQleg` активний, для нього буде створена нова сесія і повернуті її дані; в іншому випадку не буде додано жодного запису.
*Результат*: успішне виконання запиту `INSERT` з використанням `SELECT` та частини `RETURNING`.

```SQL
INSERT INTO public.sessions(user_id, refresh_token, device_type, device_name)
SELECT 
    user_id, 
    repeat('h', 96)::bytea, 
    'Tablet', 'iPad Air'
FROM public.users
WHERE
    nickname = 'ApostolQleg' AND
    user_status = 'active'
RETURNING session_id, user_id, device_name;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
*Мета*: отримати всі записи з таблиці `sessions`.
*Очікуваний результат*: всі записи з таблиці `sessions` з усіма полями (включно з `refresh_token`) будуть повернуті.
*Результат*: успішне виконання запиту `SELECT` та повернення всіх записів.

```SQL
SELECT * FROM public.sessions;
```

### Select safe session info for account settings (no `WHERE`, specified fields)
*Мета*: отримати список сесій з безпечними полями для відображення в особистому кабінеті користувача (без `refresh_token` та сирого `user_agent`).
*Очікуваний результат*: будуть повернуті всі записи з полями `session_id`, `user_id`, `device_type`, `device_name`, `os`, `browser`, `user_location`, `ip_address`.
*Результат*: успішне виконання запиту `SELECT` та повернення зазначених полів.

```SQL
SELECT 
    session_id,
    user_id, 
    device_type, 
    device_name, 
    os, browser, 
    user_location, 
    ip_address
FROM public.sessions;
```

### API production example (like in `GET /api/anime/:id/comments`, `GET /api/user` etc)
*Мета*: отримати список активних сесій конкретного користувача для відображення в налаштуваннях акаунту.
*Очікуваний результат*: повертаються дані сесій користувача `11111111-1111-4111-8111-111111111111`, термін дії яких ще не закінчився, відсортовані за часом завершення від найпізнішого.
*Результат*: успішне виконання запиту `SELECT` з використанням `WHERE` та `ORDER BY`.

`GET /api/user/11111111-1111-4111-8111-111111111111/sessions`
```SQL
SELECT 
    session_id,
    user_id, 
    device_type, 
    device_name, 
    os, browser, 
    user_location, 
    ip_address, 
    expire_time 
FROM public.sessions
WHERE 
    user_id = '11111111-1111-4111-8111-111111111111' AND 
    now() < expire_time
ORDER BY expire_time DESC;
```

### Some interesting examples

- [x] ORDER BY
- [x] LIMIT
- [x] JOIN

*Мета*: отримати 5 сесій, термін дії яких закінчується протягом наступних 7 днів, разом з даними їхніх власників.
*Очікуваний результат*: повертається список сесій із нікнеймом та email власника, відсортований за часом завершення від найближчого.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `WHERE`, `ORDER BY`, `LIMIT`.

```SQL
SELECT
    sessions.session_id,
    users.nickname,
    users.email,
    sessions.expire_time
FROM public.sessions
JOIN public.users ON
    users.user_id = sessions.user_id
WHERE
    sessions.expire_time BETWEEN now() AND
    now() + INTERVAL '7 days'
ORDER BY sessions.expire_time ASC
LIMIT 5;
```


## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: оновити термін дії, IP-адресу та місцезнаходження конкретної сесії.
*Очікуваний результат*: у сесії з ідентифікатором `1` термін дії буде подовжений на 1 рік, IP-адреса стане `192.168.1.15`, а місцезнаходження - `Lviv, Ukraine`.
*Результат*: успішне виконання запиту `UPDATE`.

```SQL
UPDATE public.sessions
SET
    expire_time = expire_time + INTERVAL '1 year',
    ip_address = '192.168.1.15',
    user_location = 'Lviv, Ukraine'
WHERE
    session_id = 1;
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: подовжити термін дії конкретної сесії та повернути оновлені значення.
*Очікуваний результат*: термін дії сесії з ідентифікатором `2` буде подовжений на 1 рік, а також будуть повернуті `session_id`, `user_id` та `expire_time`.
*Результат*: успішне виконання запиту `UPDATE` з частиною `RETURNING`.

```SQL
UPDATE sessions
SET
    expire_time = now() + INTERVAL '1 year'
WHERE
    session_id = 2
RETURNING session_id, user_id, expire_time;
```

### Some interesting examples

*Мета*: подовжити всі сесії користувача, термін дії яких закінчується протягом наступних 7 днів.
*Очікуваний результат*: усі дійсні сесії користувача `11111111-1111-4111-8111-111111111111`, що скоро закінчаться, будуть подовжені на 1 рік, а також будуть повернуті їхні нові дані.
*Результат*: успішне виконання запиту `UPDATE` з умовою за діапазоном часу та частиною `RETURNING`.

```SQL
UPDATE public.sessions
SET
    expire_time = now() + INTERVAL '1 year'
WHERE
    user_id = '11111111-1111-4111-8111-111111111111' AND
    expire_time > now() AND
    expire_time < now() + INTERVAL '7 days'
RETURNING session_id, expire_time;
```

*Мета*: завершити всі активні сесії заблокованих користувачів, використовуючи дані з таблиці `users`.
*Очікуваний результат*: у всіх сесіях користувачів зі статусом `banned`, термін дії яких ще не закінчився, `expire_time` буде встановлено на поточний час, а також будуть повернуті змінені записи.
*Результат*: успішне виконання запиту `UPDATE` з використанням `FROM` та частини `RETURNING`.

```SQL
UPDATE public.sessions
SET
    expire_time = now()
FROM public.users
WHERE 
    users.user_id = sessions.user_id AND
    users.user_status = 'banned' AND
    sessions.expire_time > now()
RETURNING sessions.session_id, sessions.user_id, sessions.expire_time;
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
*Мета*: видалити всі записи з таблиці `sessions`.
*Очікуваний результат*: всі записи з таблиці `sessions` будуть видалені.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM public.sessions;
```

### Delete with filter (`WHERE`)
*Мета*: завершити конкретну сесію користувача (вихід з акаунту на одному пристрої).
*Очікуваний результат*: сесія з ідентифікатором `1` буде видалена з таблиці.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM public.sessions
WHERE session_id = 1;
```

*Мета*: завершити всі сесії конкретного користувача (вихід з акаунту на всіх пристроях).
*Очікуваний результат*: всі сесії користувача `11111111-1111-4111-8111-111111111111` будуть видалені з таблиці.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM public.sessions
WHERE user_id = '11111111-1111-4111-8111-111111111111';
```

### Delete and return (`WHERE`, `RETURNING`)
*Мета*: видалити прострочені сесії та повернути інформацію про видалені записи.
*Очікуваний результат*: усі сесії, термін дії яких закінчився, будуть видалені, а також будуть повернуті `session_id`, `user_id`, `device_name` та `ip_address`.
*Результат*: успішне виконання запиту `DELETE` з частиною `RETURNING`.

```SQL
DELETE FROM public.sessions
WHERE expire_time < now()
RETURNING session_id, user_id, device_name, ip_address;
```

### Some interesting examples

*Мета*: завершити всі сесії користувача, окрім поточної (вихід на всіх інших пристроях).
*Очікуваний результат*: усі сесії користувача `11111111-1111-4111-8111-111111111111`, крім сесії з ідентифікатором `4`, будуть видалені, а також будуть повернуті дані видалених сесій.
*Результат*: успішне виконання запиту `DELETE` з частиною `RETURNING`.

```SQL
DELETE FROM public.sessions
WHERE
    user_id = '11111111-1111-4111-8111-111111111111' AND
    session_id <> 4
RETURNING session_id, device_name, ip_address;
```

*Мета*: видалити всі сесії деактивованих користувачів, використовуючи дані з таблиці `users`.
*Очікуваний результат*: усі сесії користувачів зі статусом `deactivated` будуть видалені, а також будуть повернуті ідентифікатори сесій та користувачів.
*Результат*: успішне виконання запиту `DELETE` з використанням `USING` та частини `RETURNING`.

```SQL
DELETE FROM public.sessions
USING public.users
WHERE
    users.user_id = sessions.user_id AND
    users.user_status = 'deactivated'
RETURNING sessions.session_id, sessions.user_id;
```
