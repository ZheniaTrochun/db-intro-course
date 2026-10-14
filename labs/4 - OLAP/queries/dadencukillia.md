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
