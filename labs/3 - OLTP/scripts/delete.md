Мета: видалити ігровий акаунт гравця з нікнеймом 'barabashik-25' по грі з назвою 'dota2'
DELETE FROM game_account
WHERE user_id = (SELECT id FROM "user" WHERE nickname = 'barabashik-25' ) AND game_id = (SELECT id FROM game WHERE game_name = 'dota2')

Використовувалися команди: DELETE та SELECT, оператори: WHERE та AND. Для динамічного пошуку значення атрибуту іншої таблиці за значенням іншого атрибуту тієї ж таблиці використовувались вкладені запити.