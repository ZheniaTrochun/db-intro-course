# comments by @ApostolQleg

## ❇️ Create table
*Мета*: створити таблицю `comments` для зберігання коментарів користувачів до аніме та індекс для швидкого отримання коментарів конкретного аніме.
*Очікуваний результат*: таблиця `comments` та індекс `idx_comments_anime_created` будуть створені в базі даних.
*Результат*: успішне виконання запитів `CREATE TABLE` та `CREATE INDEX`.

```SQL
CREATE TABLE comments(
    comment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    author_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    anime_id UUID NOT NULL REFERENCES animes(anime_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK(length(trim(content)) > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_edited BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_comments_anime_created ON comments(anime_id, created_at DESC);
```


## 🗑 Drop table
*Мета*: видалити таблицю `comments`, якщо вона існує.
*Очікуваний результат*: таблиця `comments` разом з індексом `idx_comments_anime_created` буде видалена з бази даних, якщо вона існує.
*Результат*: успішне виконання запиту `DROP TABLE`, якщо таблиця існувала.

```SQL
DROP TABLE IF EXISTS comments;
```


## ✨ Insert queries

### All colums
*Мета*: додати нові коментарі до таблиці `comments`, вказавши значення для всіх полів.
*Очікуваний результат*: у таблицю `comments` будуть додані 3 коментарі з вказаними датою створення та ознакою редагування (comment_id `1`, `2`, `3`).
*Результат*: успішне виконання запиту `INSERT` та додавання 3 нових коментарів до таблиці.

```SQL
INSERT INTO comments(author_id, anime_id, content, created_at, is_edited) VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce',
    'Comment Example 1', '2026-10-05 18:00:00Z', FALSE),
    ('67676767-6767-6767-6767-676767676767', '40404040-4040-4040-4040-404040404040',
    'Comment Example 2', '2026-10-05 18:30:00Z', FALSE),
    ('14881488-1488-1488-1488-148814881488', '34343434-3434-3434-3434-343434343434', 
    'Comment Example 3', '2026-10-05 19:00:00Z', TRUE);
```

### Mandatory only colums
*Мета*: додати нові коментарі, вказавши лише обов'язкові поля (автор, аніме та текст).
*Очікуваний результат*: у таблицю `comments` будуть додані 3 коментарі, а дата створення (`now()`) та ознака редагування (`FALSE`) встановляться автоматично.
*Результат*: успішне виконання запиту `INSERT` та додавання 3 нових коментарів до таблиці.

```SQL
INSERT INTO comments(author_id, anime_id, content) VALUES
    ('11111111-1111-4111-8111-111111111111', 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'Comment Example 4'),
    ('67676767-6767-6767-6767-676767676767', '40404040-4040-4040-4040-404040404040', 'Comment Example 5'),
    ('14881488-1488-1488-1488-148814881488', '34343434-3434-3434-3434-343434343434', 'Comment Example 6');
```

### With returning part (`RETURNING`)
*Мета*: додати новий коментар та отримати повернені дані, щоб він міг відразу відобразитися в UI.
*Очікуваний результат*: новий коментар буде доданий до таблиці `comments`, а також будуть повернуті його ідентифікатор, автор, аніме, текст та дата створення.
*Результат*: успішне виконання запиту `INSERT` з частиною `RETURNING`.

```SQL
INSERT INTO comments(author_id, anime_id, content)
VALUES ('11111111-1111-4111-8111-111111111111', '40404040-4040-4040-4040-404040404040', 'Comment Example 7')
RETURNING comment_id, author_id, anime_id, content, created_at;
```

### Some interesting examples

*Мета*: додати коментар, отримавши `author_id` та `anime_id` за допомогою підзапиту (`INSERT ... SELECT`) за нікнеймом користувача.
*Очікуваний результат*: коментар від користувача `dadencukillia` до аніме з ID `40404040-4040-4040-4040-404040404040` буде доданий до таблиці, а також буде повернуто дані про цей коментар.
*Результат*: успішне виконання запиту `INSERT` з використанням `SELECT` та частини `RETURNING`.

```SQL
INSERT INTO comments(author_id, anime_id, content)
SELECT users.user_id, animes.anime_id, 'Comment added via nickname'
FROM users
CROSS JOIN animes
WHERE users.nickname = 'dadencukillia'
    AND animes.anime_id = '40404040-4040-4040-4040-404040404040'
RETURNING comment_id, author_id, anime_id, content, created_at;
```

*Мета*: додати коментар лише у випадку, якщо акаунт користувача має статус `active` (заблоковані та деактивовані користувачі не можуть коментувати).
*Очікуваний результат*: якщо користувач активний, коментар буде доданий і повернутий; в іншому випадку не буде додано жодного запису.
*Результат*: успішне виконання запиту `INSERT` з умовою `WHERE` у підзапиті та частиною `RETURNING`.

```SQL
INSERT INTO comments(author_id, anime_id, content)
SELECT users.user_id, 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce', 'Comment only for active users'
FROM users
WHERE users.user_id = '11111111-1111-4111-8111-111111111111'
	AND users.user_status = 'active'
RETURNING comment_id, author_id, anime_id, content, created_at;
```


## 📨 Select queries

### Select all entries (no `WHERE`, all fields)
*Мета*: отримати всі записи з таблиці `comments`.
*Очікуваний результат*: всі записи з таблиці `comments` з усіма полями будуть повернуті.
*Результат*: успішне виконання запиту `SELECT` та повернення всіх записів.

```SQL
SELECT * FROM comments;
```

### Select public only info (no `WHERE`, specified fields)
*Мета*: отримати всі коментарі лише з публічними полями.
*Очікуваний результат*: будуть повернуті всі записи з полями `comment_id`, `author_id`, `anime_id`, `content`, `created_at`, `is_edited`.
*Результат*: успішне виконання запиту `SELECT` та повернення зазначених полів.

```SQL
SELECT comment_id, author_id, anime_id, content, created_at, is_edited 
FROM comments;
```

### API production example
*Мета*: отримати публічні дані коментарів до конкретного аніме разом з даними їхніх авторів для відображення на сторінці аніме. Нові коментарі йдуть першими, реалізовано ефективну курсорну пагінацію (keyset pagination по 100 записів на порцію): Backend підставляє ідентифікатор останнього отриманого коментаря у `last_comment_id` (`NULL` для першої сторінки або конкретний `comment_id` для завантаження наступної порції замість `OFFSET`).
*Очікуваний результат*: повертається список із максимум 100 коментарів до аніме з ID `f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce`, що йдуть після зазначеного курсора (`comment_id < 20`), відсортованих від найновіших за спаданням ідентифікатора, разом з ідентифікатором, нікнеймом та аватаром автора. Для отримання найпершої сторінки у CTE передається `NULL`.
*Результат*: успішне виконання запиту `SELECT` з використанням CTE (`WITH`), `JOIN`, `ORDER BY` та `LIMIT`.

`GET /api/anime/f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce/comments`
```SQL
WITH pagination AS (
    SELECT 20::bigint AS last_comment_id -- NULL, щоб отримати найпершу сторінку
)
SELECT 
    comments.comment_id,
    comments.content,
    comments.created_at,
    comments.is_edited,
    users.user_id,
    users.nickname,
    users.avatar_url
FROM comments
INNER JOIN users ON 
    users.user_id = comments.author_id
WHERE 
    comments.anime_id = 'f1cef1ce-f1ce-f1ce-f1ce-f1cef1cef1ce'
    AND (
        (SELECT last_comment_id FROM pagination) IS NULL 
        OR comments.comment_id < (SELECT last_comment_id FROM pagination)
    )
ORDER BY comments.comment_id DESC
LIMIT 100;
```

### Some interesting examples

- [x] ORDER BY
- [x] LIMIT
- [x] OFFSET
- [x] JOIN

*Мета*: отримати рейтинг найактивніших користувачів за кількістю залишених коментарів.
*Очікуваний результат*: повертається список із максимум 10 користувачів з кількістю їхніх коментарів, відсортований за кількістю у спадаючому порядку, а за однакової кількості - за нікнеймом.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `GROUP BY`, `ORDER BY`, `LIMIT` та `OFFSET`.

```SQL
SELECT
    users.nickname,
    COUNT(comments.comment_id) AS total_comments
FROM comments
JOIN users ON users.user_id = comments.author_id
GROUP BY users.user_id, users.nickname
ORDER BY total_comments DESC, users.nickname ASC
LIMIT 10 
OFFSET 10 * 0;
```

*Мета*: отримати 10 найновіших коментарів за сьогодні разом з назвами аніме, до яких вони залишені.
*Очікуваний результат*: повертається список із максимум 5 коментарів, залишених за останній тиждень, з українською назвою аніме, відсортований від найновіших.
*Результат*: успішне виконання запиту `SELECT` з використанням `JOIN`, `WHERE`, `ORDER BY`, `LIMIT` та `OFFSET`.

```SQL
SELECT
    comments.comment_id,
    comments.content,
    comments.created_at,
    animes.title_ua
FROM comments
JOIN animes ON animes.anime_id = comments.anime_id
WHERE comments.created_at >= now() - INTERVAL '1 days'
ORDER BY comments.created_at DESC
LIMIT 10 
OFFSET 10 * 0;
```


## 🔄 Update queries

### Update some fields (`WHERE`)
*Мета*: змінити текст конкретного коментарю та позначити його як відредагований.
*Очікуваний результат*: у коментарі з ідентифікатором `1` текст буде змінено на "Updated comment example 1", а поле `is_edited` отримає значення `TRUE`.
*Результат*: успішне виконання запиту `UPDATE`.

```SQL
UPDATE comments
SET content = 'Updated comment example 1',
    is_edited = TRUE
WHERE comment_id = 1;
```

### Update fields returning values (`WHERE`, `RETURNING`)
*Мета*: змінити текст конкретного коментарю та повернути оновлені значення для відображення в UI.
*Очікуваний результат*: у коментарі з ідентифікатором `2` текст буде змінено, а також будуть повернуті `comment_id`, `content`, `is_edited` та `created_at`.
*Результат*: успішне виконання запиту `UPDATE` з частиною `RETURNING`.

```SQL
UPDATE comments
SET content = 'Updated comment example 2',
    is_edited = TRUE
WHERE comment_id = 2
RETURNING comment_id, content, is_edited, created_at;
```

### Some interesting examples

*Мета*: дозволити редагування коментарю лише його автору, додавши перевірку `author_id` в умову `WHERE`.
*Очікуваний результат*: коментар з ідентифікатором `2` буде оновлений, лише якщо його автором є користувач `67676767-6767-6767-6767-676767676767`; інакше не буде змінено жодного запису.
*Результат*: успішне виконання запиту `UPDATE` з частиною `RETURNING`.

```SQL
UPDATE comments
SET content = 'Edited by the author',
    is_edited = TRUE
WHERE comment_id = 2
    AND author_id = '67676767-6767-6767-6767-676767676767'
RETURNING comment_id, author_id, content, is_edited;
```

*Мета*: приховати текст усіх коментарів заблокованих користувачів, використовуючи дані з таблиці `users`.
*Очікуваний результат*: у всіх коментарях користувачів зі статусом `banned` текст буде замінений на "[This comment is hidden]", а також будуть повернуті змінені записи.
*Результат*: успішне виконання запиту `UPDATE` з використанням `FROM` та частини `RETURNING`.

```SQL
UPDATE comments
SET content = '[This comment is hidden]',
    is_edited = TRUE
FROM users
WHERE users.user_id = comments.author_id
    AND users.user_status = 'banned'
RETURNING comments.comment_id, comments.author_id, comments.content;
```


## ⛔ Delete queries

### Clear table (no `WHERE`)
*Мета*: видалити всі записи з таблиці `comments`.
*Очікуваний результат*: всі записи з таблиці `comments` будуть видалені.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM comments;
```

### Delete with filter (`WHERE`)
*Мета*: видалити конкретний коментар за його ідентифікатором.
*Очікуваний результат*: коментар з ідентифікатором `1` буде видалений з таблиці.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM comments
WHERE comment_id = 1;
```

*Мета*: видалити всі коментарі конкретного користувача.
*Очікуваний результат*: всі коментарі користувача `67676767-6767-6767-6767-676767676767` будуть видалені з таблиці.
*Результат*: успішне виконання запиту `DELETE`.

```SQL
DELETE FROM comments
WHERE author_id = '67676767-6767-6767-6767-676767676767';
```

### Delete and return (`WHERE`, `RETURNING`)
*Мета*: видалити конкретний коментар та повернути видалені дані.
*Очікуваний результат*: коментар з ідентифікатором `1` буде видалений, а також будуть повернуті його `comment_id`, `author_id`, `anime_id` та `content`.
*Результат*: успішне виконання запиту `DELETE` з частиною `RETURNING`.

```SQL
DELETE FROM comments
WHERE comment_id = 1
RETURNING comment_id, author_id, anime_id, content;
```

### Some interesting examples

*Мета*: видалити всі коментарі заблокованих користувачів, використовуючи дані з таблиці `users`.
*Очікуваний результат*: всі коментарі користувачів зі статусом `banned` будуть видалені, а також будуть повернуті ідентифікатори та автори видалених коментарів.
*Результат*: успішне виконання запиту `DELETE` з використанням `USING` та частини `RETURNING`.

```SQL
DELETE FROM comments
USING users
WHERE users.user_id = comments.author_id
    AND users.user_status = 'banned'
RETURNING comments.comment_id, comments.author_id;
```
