# Опис SQL-запитів (`queries1.sql`)

## 1. Запити з агрегаційними функціями

### 1.1. Середня тривалість матчу

```sql
SELECT ROUND(AVG(duration_minutes), 2) AS avg_minutes
FROM Matches
```

- **Що робить:** Обчислює середнє арифметичне тривалості всіх матчів у хвилинах (`AVG`) та округлює результат до двох знаків після коми (`ROUND`).
- **Чому:** Дозволяє оцінити типову тривалість поєдинку в базі даних у зручному для читання форматі.

### 1.2. Кількість гравців за статусом кар'єри

```sql
SELECT career_status, COUNT(*) AS total_players
FROM Players
GROUP BY career_status
```

- **Що робить:** Групує записи в таблиці `Players` за полем `career_status` і підраховує кількість гравців у кожній групі (`COUNT(*)`).
- **Чому:** Дає змогу швидко отримати статистичний розподіл тенісистів на активних і тих, хто вже завершив кар'єру.

### 1.3. Статистика рейтингових очок

```sql
SELECT MAX(points) AS max_points, MIN(points) AS min_points, ROUND(AVG(points), 2) AS avg_points
FROM PlayerRankingHistory
```

- **Що робить:** Знаходить максимальне (`MAX`), мінімальне (`MIN`) та округлене середнє (`AVG`) значення рейтингових очок по всій таблиці історії рейтингів.
- **Чому:** Допомагає оцінити загальний діапазон і середній рівень очок серед усіх зафіксованих позицій у рейтингу.

---

## 2. Запити з об'єднанням таблиць (`JOIN`)

### 2.1. Завершені фінальні матчі

```sql
SELECT tournament_name, last_name AS winner_surname, court_name
FROM Matches m
INNER JOIN Tournaments AS t ON m.tournament_id = t.tournament_id
INNER JOIN Players AS p ON m.winner_id = p.player_id
INNER JOIN Courts AS c ON m.court_id = c.court_id
WHERE m.status = 'Finished' AND m.round = 'Final'
ORDER BY tournament_name
```

- **Що робить:** Об'єднує таблицю матчів із турнірами, гравцями та кортами через `INNER JOIN`, фільтрує лише завершені фінали (`status = 'Finished'` та `round = 'Final'`) і сортує результат за назвою турніру.
- **Чому:** В основній таблиці `Matches` зберігаються лише ідентифікатори (зовнішні ключі), тому `JOIN` необхідний для отримання зрозумілих назв турнірів, кортів і прізвищ переможців.

### 2.2. Усі турніри та їхні корти

```sql
SELECT t.tournament_name, c.court_name
FROM Tournaments t
LEFT JOIN Courts AS c ON t.tournament_id = c.tournament_id
```

- **Що робить:** Виводить назви всіх турнірів із таблиці `Tournaments` разом із прив'язаними до них кортами з таблиці `Courts`.
- **Чому:** Використання `LEFT JOIN` гарантує, що у списку залишаться навіть ті турніри, для яких у базі ще не додано жодного корту (у полі `court_name` для них повернеться `NULL`).

---

## 3. Запити з підзапитами

### 3.1. Гравці, вищі за середній зріст

```sql
SELECT p.first_name || ' ' || p.last_name AS full_name, p.height_cm,
	(SELECT ROUND(AVG(height_cm), 2) AS avg_height FROM Players)
FROM Players p
WHERE height_cm > (
	SELECT ROUND(AVG(p.height_cm), 2)
	FROM Players p
)
```

- **Що робить:** Формує повне ім'я гравця, виводить його зріст і порівнює його із середнім зростом усіх гравців, обчисленим у вкладеному запиті в умові `WHERE` (а також дублює це середнє значення окремим стовпцем у `SELECT`).
- **Чому:** SQL не дозволяє напряму використовувати агрегатні функції на кшталт `AVG()` у блоці `WHERE`, тому підзапит дає змогу динамічно обчислити порогове значення для фільтрації.

### 3.2. Турніри тієї ж категорії, що й Wimbledon

```sql
SELECT tournament_name
FROM Tournaments
WHERE category = (
	SELECT category
	FROM Tournaments
	WHERE tournament_name = 'Wimbledon'
)
```

- **Що робить:** Внутрішній запит визначає категорію турніру `'Wimbledon'`, а зовнішній вибирає назви всіх турнірів, які мають таку саму категорію.
- **Чому:** Дозволяє знайти аналогічні за рівнем турніри без необхідності заздалегідь знати й жорстко прописувати точну назву категорії в коді запиту.
