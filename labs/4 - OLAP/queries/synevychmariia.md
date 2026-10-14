## OLAP Queries

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