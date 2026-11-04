1. Підрахунок загальної кількості користувачів

SELECT COUNT(*) as number_of_users
FROM "user"


Цей запит виконує підрахунок загальної кількості всіх зареєстрованих користувачів у базі даних.

2. Статистика середньої, мінімальної, максимальної max_team_players команд за їх статусами

SELECT status, ROUND(AVG(max_team_players), 2), MIN(max_team_players), MAX(max_team_players)
FROM team
GROUP BY status


Цей запит виконує групування команд за їх статусом та виводить середню, мінімальну і максимальну кількість гравців для кожної групи.

3. Сума призових фондів турнірів за валютами

SELECT currency, SUM(prize_pool)
FROM tournament
GROUP BY currency


Цей запит виконує підрахунок сумарного призового фонду всіх турнірів із групуванням за типом валюти.

4. Турніри, що мають більше ніж одну заявку

SELECT t.id, COUNT(*) as number_of_applications
FROM tournament as t
INNER JOIN tournament_application as ta ON t.id = ta.tournament_id
GROUP BY t.id
HAVING COUNT(*) > 1


Цей запит виконує виведення ідентифікаторів турнірів, на які подано більше однієї заявки.

5. Турніри та команди, що беруть участь

SELECT t.id as tournament_id, team.name as team_participant
FROM tournament as t
INNER JOIN tournament_application as ta ON t.id = ta.tournament_id
INNER JOIN team ON ta.team_id = team.id


Цей запит виконує виведення списку ідентифікаторів турнірів та назв команд, які беруть у них участь.

6. Всі ігри та їхні турніри

SELECT g.game_name, t.name
FROM game as g
LEFT JOIN tournament as t ON g.id = t.game_id
ORDER BY g.game_name ASC


Цей запит виконує виведення списку всіх ігор та пов'язаних з ними турнірів, включаючи ігри без створених турнірів.

7. Користувачі та їх ігрові акаунти

SELECT g.game_name, u.nickname
FROM game as g
INNER JOIN game_account as ga ON ga.game_id = g.id
RIGHT JOIN "user" as u ON u.id = ga.user_id
ORDER BY g.game_name ASC


Цей запит виконує виведення нікнеймів усіх користувачів та прив'язаних до них ігрових акаунтів, включаючи користувачів без акаунтів.

8. Гравці, середня кількість вбивств яких, більша за загальну середню кількість вбивств

SELECT u.nickname, AVG(ps.kills)
FROM "user" as u
INNER JOIN player_statistic as ps ON ps.user_id = u.id
GROUP BY u.id
HAVING AVG(ps.kills) > (SELECT AVG(kills) FROM player_statistic)


Цей запит виконує пошук користувачів, чия середня кількість вбивств перевищує загальне середнє значення по всіх гравцях.

9. Кількість акаунтів ігор по яким проводилися турніри з призовим більше 1000000

SELECT g.game_name, COUNT(ga.game_account_id) as number_of_accounts
FROM game as g
LEFT JOIN game_account as ga ON ga.game_id = g.id
WHERE g.id IN (SELECT game_id FROM tournament WHERE prize_pool > 1000000)
GROUP BY g.id


Цей запит виконує підрахунок кількості прив'язаних акаунтів для тих ігор, за якими проводилися турніри з призовим фондом понад 1 000 000.

10. Матчі гравця де кількість вбивств у матчі більша за середню кількість вбивств цього гравця(через проміжну таблицю)

SELECT u.nickname, ps.match_id
FROM "user" as u
INNER JOIN (SELECT ps.user_id, AVG(ps.kills) as avg 
FROM player_statistic as ps
GROUP BY ps.user_id) as temp ON temp.user_id = u.id
INNER JOIN player_statistic as ps ON u.id = ps.user_id
WHERE ps.kills > temp.avg


Цей запит виконує виведення матчів, у яких кількість вбивств гравця перевищує його особисте середнє значення, з використанням некорельованого підзапиту.

11. Матчі гравця де кількість вбивств у матчі більша за середню кількість вбивств цього гравця(через корельований підзапит)

SELECT u.nickname, ps.match_id
FROM "user" as u
INNER JOIN player_statistic as ps ON ps.user_id = u.id
WHERE ps.kills > (
    SELECT AVG(kills)
    FROM player_statistic as ps_inner
    WHERE ps_inner.user_id = u.id
)


Цей запит виконує виведення матчів, у яких кількість вбивств гравця перевищує його особисте середнє значення, з використанням корельованого підзапиту.