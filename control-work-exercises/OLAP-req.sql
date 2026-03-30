-- Знайти лоти з найбільшою кількістю ставок
SELECT l.title AS title, COUNT(b.bid_id) AS total_bids
FROM lots l
INNER JOIN bids b using(lot_id)
GROUP BY l.lot_id, l.title
ORDER BY total_bids DESC;
-- Обчислити середню фінальну ціну за категоріями
SELECT c.name AS category_name, ROUND(AVG(s.final_price), 2) AS average_price
FROM category c 
INNER JOIN lots l ON c.category_id = l.category_id
INNER JOIN sales s using(lot_id)
GROUP BY c.category_id, c.name;
-- Ранжувати користувачів за загальною сумою виграних аукціонів (віконні функції)
SELECT u.username, SUM(s.final_price) AS total_spent, RANK() OVER (ORDER BY SUM(s.final_price) DESC) AS buyer_rank
FROM users u
INNER JOIN sales s ON u.user_id = s.buyer_id
GROUP BY u.user_id, u.username;
-- Знайти лоти, які не отримали жодної ставки
SELECT l.lot_id, l.title as lot_title
FROM lots l
LEFT JOIN bids b using(lot_id)
WHERE b.bid_id IS NULL;