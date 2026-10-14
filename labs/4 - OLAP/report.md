# By @XxMariavxX
## Рахує кількість аніме за статусом
Опис: Цей запит підраховує кількість доступних аніме (available = TRUE) за їхнім статусом (upcoming, ongoing, cancelled, finished). Аніме без визначеного статусу (anime_status IS NOT NULL) не враховуються. Результат групується за статусом і сортується за кількістю аніме у спадному порядку.

```SQL
SELECT
    anime_status,
    count(*) AS total_count_animes
FROM public.animes
WHERE available = TRUE
  AND anime_status IS NOT NULL
GROUP BY anime_status
ORDER BY total_count_animes DESC;
```

## Статистика аніме за студією
Опис: Цей запит групує аніме за студією виробництва та для кожної студії обчислює кількість тайтлів (`COUNT`), загальну кількість серій (`SUM`) і середню тривалість серії (`AVG`). Порожні назви студій відкидаються (production_studio <> ''), бо колонка має значення за замовчуванням ''. Нульова тривалість серії (значення за замовчуванням) ігнорується через `NULLIF`, щоб не занижувати середнє. Результат відсортовано за загальною кількістю серій у спадному порядку.

```SQL
SELECT
    production_studio,
    count(*),
    sum(episodes_count),
    round(avg(NULLIF(avg_episode_duration, 0)), 1)
FROM public.animes
WHERE production_studio <> ''
GROUP BY production_studio
ORDER BY sum(episodes_count) DESC, production_studio;
```

## Статистика аніме за форматом
Опис: Цей запит групує аніме за форматом (tv, ova, ona, movie, special, music, other) і для кожного формату повертає кількість тайтлів (`COUNT`), середню (`AVG`), максимальну (`MAX`) та мінімальну (`MIN`) кількість серій. Результат відсортовано за кількістю тайтлів у спадному порядку.

```SQL
SELECT
    anime_format,
    count(*),
    round(avg(episodes_count), 1),
    max(episodes_count),
    min(episodes_count)
FROM public.animes
GROUP BY anime_format
ORDER BY count(*) DESC;
```

------

## Рахує кількість аніме за жанром (LEFT JOIN)
Опис: Цей запит підраховує кількість аніме для кожного жанру. Список усіх жанрів береться з enum `genre_type_enum` через `unnest(enum_range(...))`, а до нього через `LEFT JOIN` приєднується таблиця `genres`. Завдяки цьому в результат потрапляють і жанри, до яких не прив'язано жодного аніме (для них кількість дорівнює 0). Результат сортується за кількістю аніме у спадному порядку, а потім за назвою жанру.

```SQL
SELECT
    unnest,
    count(public.genres.anime_id)
FROM unnest(enum_range(NULL::public.genre_type_enum))
LEFT JOIN public.genres ON public.genres.genre_type = unnest
GROUP BY unnest
ORDER BY count(public.genres.anime_id) DESC, unnest;
```

## Рахує кількість аніме за жанром, де кількість аніме більше 2
Опис: Цей запит підраховує кількість аніме за жанром, але повертає лише ті жанри, де кількість аніме перевищує 2. Фільтрація виконується через `HAVING`, бо умова стосується агрегованого значення, а не окремих рядків. Результат сортується за кількістю аніме у спадному порядку.

```SQL
SELECT
    genre_type,
    count(*)
FROM public.genres
GROUP BY genre_type
HAVING count(*) > 2
ORDER BY count(*) DESC, genre_type;
```

---------
## Рахує кількість епізодів, що виходять сьогодні, для кожного доступного аніме (INNER JOIN)
Опис: Цей запит використовує `INNER JOIN` для об'єднання таблиць `animes` та `upcoming_episodes`. Він залишає лише доступні аніме (available = TRUE), у яких дата виходу епізоду припадає на поточну добу, групує результат за ідентифікатором аніме (щоб різні аніме з однаковими назвами не зливалися) і повертає кількість епізодів, що виходять сьогодні. Умова за датою записана як діапазон (від початку поточної доби до початку наступної), щоб не приводити тип для кожного рядка.

```SQL
SELECT
        public.animes.anime_id,
        public.animes.title_ua,
        public.animes.title_en,
        count(public.upcoming_episodes.episode_name)
FROM public.animes
INNER JOIN public.upcoming_episodes ON public.upcoming_episodes.anime_id = public.animes.anime_id
WHERE public.animes.available = TRUE
    AND public.upcoming_episodes.episode_date >= current_date
    AND public.upcoming_episodes.episode_date <  current_date + 1
GROUP BY public.animes.anime_id, public.animes.title_ua, public.animes.title_en
ORDER BY count(public.upcoming_episodes.episode_name) DESC;
```

## Рахує всі заплановані епізоди для кожного аніме
Опис: Цей запит підраховує кількість усіх епізодів у розкладі (таблиця `upcoming_episodes`) для кожного аніме. За допомогою `INNER JOIN` до результату додається назва тайтлу з таблиці `animes`. Результат групується за ідентифікатором аніме та сортується за кількістю запланованих епізодів у спадному порядку.

```SQL
SELECT
    public.animes.anime_id,
    public.animes.title_ua,
    count(public.upcoming_episodes.episode_name)
FROM public.upcoming_episodes
INNER JOIN public.animes ON public.animes.anime_id = public.upcoming_episodes.anime_id
GROUP BY public.animes.anime_id, public.animes.title_ua
ORDER BY count(public.upcoming_episodes.episode_name) DESC;
```

## Аніме, у яких у розкладі більше одного епізоду
Опис: Цей запит підраховує кількість епізодів у розкладі для кожного аніме та повертає лише ті аніме, у яких у розкладі більше одного епізоду. Фільтрація за кількістю виконується через `HAVING`.

```SQL
SELECT
    anime_id,
    count(episode_name)
FROM public.upcoming_episodes
GROUP BY anime_id
HAVING count(episode_name) > 1
ORDER BY count(episode_name) DESC;
```

---------
## Аніме з кількістю серій більшою за середню (підзапит у WHERE)
Опис: Цей запит повертає аніме, у яких кількість серій перевищує середню по всій базі. Середнє значення обчислюється вкладеним підзапитом у `WHERE`, який виконується один раз. Аніме з нульовою кількістю серій (значення за замовчуванням) не враховуються при обчисленні середнього, щоб не занижувати його.

```SQL
SELECT title_ua, episodes_count
FROM public.animes
WHERE episodes_count > (
    SELECT avg(episodes_count)
    FROM public.animes
    WHERE episodes_count > 0
)
ORDER BY episodes_count DESC;
```

## Студії з середньою кількістю серій вище загальної середньої (підзапит у HAVING)
Опис: Цей запит групує аніме за студією та повертає лише ті студії, у яких середня кількість серій вища за середню по всій базі. Середнє по базі обчислюється підзапитом у реченні `HAVING`; аніме з нульовою кількістю серій (значення за замовчуванням) у ньому не враховуються, щоб не занижувати середнє (так само, як у запиті з підзапитом у `WHERE`). Студії з порожньою назвою відкидаються

```SQL
SELECT
    production_studio,
    round(avg(episodes_count), 1)
FROM public.animes
WHERE production_studio <> ''
GROUP BY production_studio
HAVING avg(episodes_count) > (SELECT avg(episodes_count) FROM public.animes WHERE episodes_count > 0)
ORDER BY round(avg(episodes_count), 1) DESC;
```

## Топ 10 аніме за кількістю завантажених серій (підзапит у SELECT)
Опис: Цей запит для кожного аніме обчислює кількість завантажених серій за допомогою корельованого підзапиту в `SELECT` (підзапит звертається до таблиці `episodes` і залежить від поточного рядка `animes`). Результат сортується за кількістю серій у спадному порядку та обмежується 10 записами.

```SQL
SELECT
    public.animes.title_ua,
    (SELECT count(*)
    FROM public.episodes
    WHERE public.episodes.anime_id = public.animes.anime_id)
FROM public.animes
ORDER BY (SELECT count(*)
        FROM public.episodes
        WHERE public.episodes.anime_id = public.animes.anime_id) DESC,
        public.animes.title_ua
LIMIT 10;
```

---------
## Звірка користувачів зі списками аніме (FULL JOIN)
Опис: Цей запит за допомогою `FULL JOIN` об'єднує таблиці `users` та `anime_list_units` і для кожної пари значень user_id підраховує кількість записів у списку. У результаті видно користувачів без жодного запису у списку (units = 0) та «осиротілі» записи, у яких user_id відсутній у таблиці `users`. Такі записи можливі, бо в `anime_list_units.user_id` не задано зовнішній ключ.

```SQL
SELECT
    public.users.user_id,
    public.anime_list_units.user_id,
    count(public.anime_list_units.anime_id)
FROM public.users
FULL JOIN public.anime_list_units ON public.anime_list_units.user_id = public.users.user_id
GROUP BY public.users.user_id, public.anime_list_units.user_id
ORDER BY count(public.anime_list_units.anime_id) DESC;
```

## Середня оцінка за жанром (багатотабличне об'єднання з агрегацією)
Опис: Цей запит об'єднує три таблиці (`genres`, `animes`, `anime_list_units`) через `INNER JOIN`, залишає лише доступні аніме та записи з виставленою оцінкою (grade IS NOT NULL), групує результат за жанром і обчислює кількість оцінок та середню оцінку користувачів. Через `HAVING` відсіюються жанри, у яких менше 3 оцінок. Оцінка (grade) змінюється від -5 до 5.

```SQL
SELECT
        public.genres.genre_type,
        count(*),
        round(avg(public.anime_list_units.grade), 2)
FROM public.genres
INNER JOIN public.animes ON public.animes.anime_id = public.genres.anime_id
INNER JOIN public.anime_list_units ON public.anime_list_units.anime_id = public.animes.anime_id
WHERE public.animes.available = TRUE
    AND public.anime_list_units.grade IS NOT NULL
GROUP BY public.genres.genre_type
HAVING count(*) >= 3
ORDER BY round(avg(public.anime_list_units.grade), 2) DESC;
```
## Аніме з найбільшою кількістю серій
Опис: Цей запит повертає аніме з найбільшою кількістю серій. Він використовує підзапит у `WHERE`, щоб знайти максимальну кількість серій серед усіх аніме, і повертає всі тайтли, які мають цю кількість серій (у випадку, якщо таких тайтлів декілька). Результат сортується за назвою тайтлу.

```SQL
SELECT title_ua, episodes_count
FROM public.animes
WHERE episodes_count = (SELECT max(episodes_count) FROM public.animes);
```

# By @ApostolQleg
## Запит, що повертає топ 10 найактивніших коментаторів
**Опис**: Запит підраховує загальну кількість коментарів для кожного користувача за допомогою `INNER JOIN` та повертає 10 найактивніших авторів у порядку спадання кількості коментарів.

**Використано:** `COUNT`, `GROUP BY`, `INNER JOIN`.
```SQL
SELECT
    users.nickname,
    count(comments.comment_id) AS total_comments
FROM public.comments
INNER JOIN public.users ON
    users.user_id = comments.author_id
GROUP BY users.user_id, users.nickname
ORDER BY total_comments DESC, users.nickname ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 людей за кількістю завершених аніме
**Опис:** Запит групує користувачів і підраховує кількість аніме зі статусом «finished» у їхніх списках, повертаючи перших 10 людей.

**Використано:** `COUNT`, `GROUP BY`, `LEFT JOIN`.
```SQL
SELECT
    users.nickname,
    count(list_unit.anime_id) AS finished_count
FROM public.users
LEFT JOIN public.anime_list_units list_unit ON
    users.user_id = list_unit.user_id
    AND list_unit.list_unit_status = 'finished'
GROUP BY users.user_id, users.nickname
ORDER BY finished_count DESC, users.nickname ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 аніме за кількістю коментарів
**Опис:** Запит агрегує коментарі для кожного тайтлу через `RIGHT JOIN` (демонстративний приклад) та виводить 10 найбільш обговорюваних аніме.

**Використано:** `COUNT`, `GROUP BY`, `RIGHT JOIN`
```SQL
SELECT
    animes.title_ua,
    count(comments.comment_id) AS total_comments
FROM public.comments
RIGHT JOIN public.animes ON
    animes.anime_id = comments.anime_id
GROUP BY animes.anime_id, animes.title_ua
ORDER BY total_comments DESC, animes.title_ua ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 жанрів за кількістю коментарів відповідних аніме
**Опис:** Запит об'єднує жанри з коментарями відповідних аніме через `INNER JOIN`, підраховує загальну кількість коментарів у межах кожного жанру та повертає 10 найпопулярніших жанрів за кількістю коментарів.

**Використано:** `COUNT`, `GROUP BY`, `INNER JOIN`
```SQL
SELECT
    genres.genre_type,
    count(comments.comment_id) AS total_comments
FROM public.genres
INNER JOIN public.comments ON
    comments.anime_id = genres.anime_id
GROUP BY genres.genre_type
ORDER BY total_comments DESC, genres.genre_type ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає топ 10 регіонів за і з відсотком сесій користувачів в цьому регіоні
**Опис:** Запит підраховує кількість сесій для кожного визначеного регіону та обчислює його відсоткову частку від загальної кількості всіх сесій за допомогою вкладеного підзапиту `SELECT`, повертаючи 10 найпопулярніших регіонів.

**Використано:** багато `COUNT`, `GROUP BY`, підзапит `SELECT`
```SQL
SELECT
    sessions.user_location,
    count(sessions.session_id) AS total_sessions,
    round(
        (count(sessions.session_id) * 100.0) / (SELECT count(*) FROM public.sessions), 2) 
    AS session_percentage
FROM public.sessions
WHERE sessions.user_location IS NOT NULL
GROUP BY sessions.user_location
ORDER BY total_sessions DESC, sessions.user_location ASC
LIMIT 10 
OFFSET 10 * 0;
```

## Запит, що повертає дуже багато статистичної публічної інформації користувача для профілю
**Опис:** Комплексний агрегуючий запит для формування картки профілю. Обчислює розмір списку, кількість завершених аніме, сумарно переглянуті епізоди, проглянуті години та середню оцінку від користувача через `LEFT JOIN`.

**Використано:** `COUNT`, `SUM`, `AVG`, `FILTER`, `COALESCE`, `ROUND`, `GROUP BY`, багатотабличний `LEFT JOIN`, підзапит`SELECT`
```SQL
SELECT
    u.user_id, 
    u.nickname,
    count(lu.anime_id) AS list_size,
    count(*) FILTER (WHERE lu.list_unit_status = 'finished') AS finished,
    coalesce(sum(lu.watched_episodes), 0) AS episodes_watched,
    round(coalesce(sum(lu.watched_episodes * a.avg_episode_duration), 0) / 60.0, 1) AS hours_watched,
    round(avg(lu.grade), 2) AS avg_grade,
    (
        SELECT count(*) 
        FROM public.comments c 
        WHERE c.author_id = u.user_id
    ) AS comments_total
FROM public.users u
LEFT JOIN public.anime_list_units lu ON lu.user_id = u.user_id
LEFT JOIN public.animes a ON a.anime_id = lu.anime_id
WHERE u.user_id = '14881488-1488-1488-1488-148814881488'
GROUP BY u.user_id, u.nickname;
```
# By @dadencukillia
## Вирахування оцінки та повернення полей аніме
Проходиться по всім anime_list_units та збирає середнє арифметичне всіх значень полей grade.
Додатково повертає інформацію про саме аніме.

```SQL
SELECT
    a.anime_id, a.slug, a.title_ua,
    round(avg(lu.grade), 0) AS grade,
    count(lu.grade) AS grades_count
FROM public.anime_list_units lu
INNER JOIN animes AS a ON
    a.anime_id = lu.anime_id
WHERE
    lu.anime_id = '40404040-4040-4040-4040-404040404040' -- replace ID here
GROUP BY a.anime_id, a.slug, a.title_ua;
```

## Недоперекладені аніме
Бере найбільшу кількість перекладених серій від студії (також диференціює по типу) та перевіряє кількість серій в самому тайтлі.
Якщо та кількість перекладених серій менша за кількість в тайтлі - аніме недоперекладене.

Даний приклад мав два способи реалізації:
1. Порахувати кількість епізодів до певного тайтлу.
    Проблема: різні студії можуть робити різні переклади під одні й ті самі серії, тому кількість майже гарантовано буде не правильною.
1. Взяти найбільшу кількість перекладених серій окремо від студій.
    Проблема: рідко буває, що деякі студії припиняють переклад (частим прикладом є QTV), але інші студії починають переклад не з нуля,
    а продовжують з останньої перекладеної серії іншої студії. Тож у таких випадках кількість перекладених серій буде менша ніж на справді.

Тож, за такої умови цей приклад не можна назвати ніяк інакше як **демонстративним** ✨.

**P.S.:** CROSS JOIN тут краще було б замінити на INNER JOIN, але я хочу показати на скільки багато типів JOIN я знаю.

```SQL
SELECT a.anime_id, b.episodes_count AS anime_episodes, max(a.translated_eps) AS translated_episodes
FROM (
    SELECT anime_id, localization_studio, localization_type, count(*) AS translated_eps
    FROM public.episodes
    GROUP BY anime_id, localization_studio, localization_type
) a
CROSS JOIN public.animes b
WHERE
    b.anime_id = a.anime_id
GROUP BY a.anime_id, b.episodes_count
HAVING
    b.episodes_count IS NULL
    OR max(a.translated_eps) < b.episodes_count;
```

## Кількість покинутих anime_list_units (якщо юзер кудись зник)
Проходиться по anime_list_units та використовує особливість `LEFT JOIN` (який лишає NULL поля, якщо записи по критерію не були знайдені),
щоб відсіяти записи до яких було знайдено користувача.

**P.S.:** Нагадую, що у нас було вирішено поле user_id в anime_list_units зробити без FK.

```SQL
SELECT count(*)
FROM public.anime_list_units lu
LEFT JOIN public.users u ON
    u.user_id = lu.user_id
WHERE u.user_id IS NULL;
```

## Найулюбленіші жанри юзера
Бере топ 5 жанрів користувача по тим аніме, що він бачив (доступна пагінація).
Повертає жанри та їх ранги (по попередньо порахованою кількістю).

```SQL
SELECT 
    a.genre_type,
    rank() OVER (ORDER BY a.watched_times DESC) AS genre_rank
FROM (
    SELECT g.genre_type, count(*) AS watched_times
    FROM public.anime_list_units lu
    INNER JOIN public.genres g ON
        g.anime_id = lu.anime_id
    WHERE
        lu.user_id = '14881488-1488-1488-1488-148814881488' -- replace ID here
    GROUP BY g.genre_type
) a
ORDER BY genre_rank ASC
LIMIT 5
OFFSET 5 * 0;
```


## Тривіальний запит для підрахунку індексу терплячості жанрів
Дуже крутий запит, щоб зайвий раз переконатися у тому, що ніхто не любить
еччі, але всі дивляться ісекаї.
А якщо серйозно, то цей запит показує на скільки глядачі додивлюються тайтли окремих жанрів.
Безкорисно? Так воно і є. Цікаво? Мабуть так.

```SQL
SELECT
    g.genre_type,
    coalesce(avg(lu.watched_episodes), 0) / greatest(1, max(a.episodes_count)) AS patience_index
FROM public.genres g
INNER JOIN public.animes a ON
    a.anime_id = g.anime_id
LEFT JOIN public.anime_list_units lu ON
    lu.anime_id = g.anime_id
    AND lu.list_unit_status <> 'watching'
GROUP BY g.genre_type
ORDER BY patience_index DESC;
```

