Мета: змінити статус команди з назвою 'NAVI' на 'deleted' у турнірі з назвою 'CS2 Major'

UPDATE tournament_application
SET status = 'deleted'
WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI') AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')


Використовувалися команди: UPDATE та SELECT, оператори: WHERE та AND. Для динамічного пошуку значення атрибуту іншої таблиці за значенням іншого атрибуту тієї ж таблиці використовувались вкладені запити.