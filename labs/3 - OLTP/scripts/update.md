Мета: змінити статус команди з назвою 'NAVI' на 'deleted' у турнірі з назвою 'CS2 Major'

UPDATE tournament_application
SET status = 'deleted'
WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')

Мета: змінити суму призового фонду усіх турнірів де організатор 'hacker228'

UPDATE tournament
SET prize_pool = 103.73
WHERE organizer_id = (SELECT id FROM "user" WHERE nickname = 'hacker228')

Використовувалися команди: UPDATE та SELECT, оператори: WHERE та AND. Для динамічного пошуку значення атрибуту іншої таблиці за значенням іншого атрибуту тієї ж таблиці використовувались вкладені запити.