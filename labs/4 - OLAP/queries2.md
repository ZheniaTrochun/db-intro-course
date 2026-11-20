## 1. Агрегація та групування

**Запит 1.1:**
  **Що робить:** рахує загальну кількість зіграних сетів (`COUNT(*)`) та знаходить найбільшу кількість виграних ігор першим гравцем в одному сеті (`MAX(player1_games)`) у таблиці `MatchSets`
  **Чому так:** агрегатні функції дозволяють швидко отримати зведену статистику по всій таблиці без виведення кожного окремого рядка

  ```sql
  SELECT 
      COUNT(*) AS total_sets, 
      MAX(player1_games) AS max_player1_games 
  FROM MatchSets;
  ```

**Запит 1.2:**
  **Що робить:** рахує кількість турнірів для кожного типу покриття кортів (`surface`) у таблиці `Tournaments`
  **Чому так:** оператор `GROUP BY surface` об'єднує однакові покриття в групи, щоб `COUNT(*)` порахував турніри окремо по кожній категорії (`Hard`, `Clay`, `Grass`), а не загальною сумою


  ```sql
  SELECT 
      surface, 
      COUNT(*) AS tournament_count 
  FROM Tournaments 
  GROUP BY surface;
  ```

**Запит 1.3:**
  **Що робить:** підсумовує кількість ейсів (`SUM(aces)`) для кожного гравця з таблиці `PlayerMatchStatistics` та сортує результат за спаданням
  **Чому так:** групування за `player_id` збирає статистику всіх матчів одного тенісиста в один показник, а `ORDER BY total_aces DESC` одразу виводить лідерів на початок

 
  ```sql
  SELECT 
      player_id, 
      SUM(aces) AS total_aces 
  FROM PlayerMatchStatistics 
  GROUP BY player_id 
  ORDER BY total_aces DESC;
  ```

## 2. Об'єднання таблиць (`JOIN`)

**Запит 2.1:**
  **Що робить:** виводить прізвища чемпіонів та назви турнірів, у яких вони здобули титули
  **Чому так:** таблиця `PlayerTitles` зберігає лише `UUID` переможця та турніру, тому я використала подвійний `INNER JOIN` із таблицями `Players` та `Tournaments`, щоб підтягнути текстові назви замість ідентифікаторів

 
  ```sql
  SELECT 
      p.last_name, 
      t.tournament_name 
  FROM PlayerTitles pt
  JOIN Players p ON pt.player_id = p.player_id
  JOIN Tournaments t ON pt.tournament_id = t.tournament_id;
  ```

**Запит 2.2:**
  **Що робить:** формує список усіх гравців разом з іменами та прізвищами їхніх тренерів
  **Чому так:** використала саме `LEFT JOIN`, щоб у вибірці залишилися всі тенісисти з таблиці `Players`, навіть якщо для когось із них у `Coaches` ще не вказано тренера (у такому разі поля тренера відобразяться як `NULL`)


  ```sql
  SELECT 
      p.first_name AS player_first_name, 
      p.last_name AS player_last_name, 
      c.first_name AS coach_first_name, 
      c.last_name AS coach_last_name
  FROM Players p
  LEFT JOIN Coaches c ON p.player_id = c.player_id;
  ```


## 3. Підзапити

**Запит 3.1:**
  **Що робить:** знаходить усі турніри з таблиці `Tournaments`, які проходять у країні походження тенісистки Coco Gauff
  **Чому так:** скалярний підзапит у `WHERE` динамічно отримує `country_code` гравчині з таблиці `Players`, що дозволяє не прописувати код країни вручну

 
  ```sql
  SELECT * 
  FROM Tournaments 
  WHERE country_code = (
      SELECT country_code 
      FROM Players 
      WHERE first_name = 'Coco' AND last_name = 'Gauff'
  );
  ```

**Запит 3.2:**
  **Що робить:** повертає повну інформацію про матчі з найбільшою тривалістю (`duration_minutes`) у таблиці `Matches`
  **Чому так:** винесла `MAX(duration_minutes)` у вкладений підзапит, оскільки в SQL агрегатні функції не можна використовувати напряму в умові фільтрації `WHERE`


  ```sql
  SELECT * 
  FROM Matches 
  WHERE duration_minutes = (
      SELECT MAX(duration_minutes) 
      FROM Matches
  );
  ```