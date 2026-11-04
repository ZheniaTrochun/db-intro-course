SELECT COUNT(*) as number_of_users
FROM "user"


SELECT status, ROUND(AVG(max_team_players), 2), MIN(max_team_players), MAX(max_team_players)
FROM team
GROUP BY status


SELECT currency, SUM(prize_pool)
FROM tournament
GROUP BY currency


SELECT t.id, COUNT(*) as number_of_applications
FROM tournament as t
INNER JOIN tournament_application as ta ON t.id = ta.tournament_id
GROUP BY t.id
HAVING COUNT(*) > 1


SELECT t.id as tournament_id, team.name as team_participant
FROM tournament as t
INNER JOIN tournament_application as ta ON t.id = ta.tournament_id
INNER JOIN team ON ta.team_id = team.id


SELECT g.game_name, t.name
FROM game as g
LEFT JOIN tournament as t ON g.id = t.game_id
ORDER BY g.game_name ASC


SELECT g.game_name, u.nickname
FROM game as g
INNER JOIN game_account as ga ON ga.game_id = g.id
RIGHT JOIN "user" as u ON u.id = ga.user_id
ORDER BY g.game_name ASC


SELECT u.nickname, AVG(ps.kills)
FROM "user" as u
INNER JOIN player_statistic as ps ON ps.user_id = u.id
GROUP BY u.id
HAVING AVG(ps.kills) > (SELECT AVG(kills) FROM player_statistic)


SELECT g.game_name, COUNT(ga.game_account_id) as number_of_accounts
FROM game as g
LEFT JOIN game_account as ga ON ga.game_id = g.id
WHERE g.id IN (SELECT game_id FROM tournament WHERE prize_pool > 1000000)
GROUP BY g.id


SELECT u.nickname, ps.match_id
FROM "user" as u
INNER JOIN (SELECT ps.user_id, AVG(ps.kills) as avg 
FROM player_statistic as ps
GROUP BY ps.user_id) as temp ON temp.user_id = u.id
INNER JOIN player_statistic as ps ON u.id = ps.user_id
WHERE ps.kills > avg


SELECT u.nickname, ps.match_id
FROM "user" as u
INNER JOIN player_statistic as ps ON ps.user_id = u.id
WHERE ps.kills > (SELECT AVG(kills)
FROM player_statistic as ps_inner
WHERE ps_inner.user_id = u.id)




