Мета: видалити ігровий акаунт гравця з нікнеймом 'barabashik-25' по грі з назвою 'dota2'
DELETE FROM game_account
WHERE user_id = (SELECT id FROM "user" WHERE nickname = 'barabashik-25' ) AND game_id = (SELECT id FROM game WHERE game_name = 'dota2')

Мета: видалити користувача з поштою "kolya@gmail.com" в команді "NAVI"

DELETE FROM team_member
WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI' ) AND user_id = (SELECT id FROM "user" WHERE email = 'kolya@gmail.com' )

Мета: видалити статистику гравця із заданим id у певному матчі із заданим id

DELETE FROM player_statistic
WHERE user_id = 'f96728c9-95e0-4ba0-847b-850c239fce9b' AND match_id = '62a4f286-9d2e-4ec1-8eab-5c743e240a78'

Мета: видалити турнір із заданим id

DELETE FROM tournament
WHERE id = 'c962c2bf-e508-4117-b4d5-4ac49bfe96c1'

Використовувалися команди: DELETE та SELECT, оператори: WHERE та AND. Для динамічного пошуку значення атрибуту іншої таблиці за значенням іншого атрибуту тієї ж таблиці використовувались вкладені запити.