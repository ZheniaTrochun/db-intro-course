Мета: видалити ігровий акаунт гравця з нікнеймом 'barabashik-25' по грі з назвою 'dota2'
DELETE FROM game_account
WHERE user_id = (SELECT id FROM "user" WHERE nickname = 'barabashik-25' ) AND game_id = (SELECT id FROM game WHERE game_name = 'dota2')

Мета: видалити користувача з поштою "kolya@gmail.com" в команді "NAVI"

DELETE FROM team_member
WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI' ) AND user_id = (SELECT id FROM "user" WHERE email = 'kolya@gmail.com' )

Використовувалися команди: DELETE та SELECT, оператори: WHERE та AND. Для динамічного пошуку значення атрибуту іншої таблиці за значенням іншого атрибуту тієї ж таблиці використовувались вкладені запити.