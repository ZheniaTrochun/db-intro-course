Мета: отримати назви усіх турнірів, яка мають статус реєстрації

SELECT name
FROM tournament
WHERE status = 'registration'

Мета: отримати id усіх гравців, які належать до команди з назвою NAVI

SELECT user_id 
FROM team_member
WHERE team_id = (SELECT id FROM team WHERE name = 'NAVI')

Мета: отримати id усіх команд, що беруть участь у турнірі з назвою 'CS2 Major'

SELECT team_id 
FROM tournament_application
WHERE tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major' )


Мета: отримати id заявок моманд на турнір з назвою 'CS2 Major', які брали участь у першому пів фіналі

SELECT tournament_application_id_1, tournament_application_id_2
FROM encounter
WHERE stage = 'Semi-final 1' AND tournament_id = (SELECT id FROM tournament WHERE name = 'CS2 Major')

Використовувалися команди: SELECT і оператори: WHERE та AND. Для динамічного пошуку значення атрибуту іншої таблиці за значенням іншого атрибуту тієї ж таблиці використовувались вкладені запити.