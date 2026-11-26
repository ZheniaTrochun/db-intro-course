--Знайти всі активні лоти в категорії
--Запит шукає активні слоти для всіх категорій, якщо треба для конретної то достаньо додати в умову AND category.name = '...'
SELECT lot.id, lot.name as lot_name, lc.category_id, c.name as category_name
FROM lot
INNER JOIN lot_category as lc ON lot.id = lc.lot_id
LEFT JOIN category as c ON c.id = lc.category_id
WHERE lot.status = 'active'
ORDER BY c.name;

--Вивести список усіх ставок на конкретний лот
SELECT lot.id as lot_id, lot.name as lot_name, bet.id as bet_id, bet.amount, lot.currency
FROM lot
LEFT JOIN bet ON bet.lot_id = lot.id
WHERE lot.id = 1
ORDER BY amount DESC;

--Знайти лоти з найбільшою кількістю ставок
SELECT lot.id as lot_id, lot.name as lot_name, COUNT(bet.id) as amount_of_bets
FROM lot
LEFT JOIN bet ON bet.lot_id = lot.id
GROUP BY lot.id
ORDER BY amount_of_bets DESC;

--Обчислити середню фінальну ціну за категоріями
SELECT c.id as category_id, c.name as category_name, ROUND(AVG(bet.amount),2) as average_final_price
FROM category as c
INNER JOIN lot_category as lc ON c.id = lc.category_id
INNER JOIN bet ON bet.lot_id = lc.lot_id
WHERE bet.status = 'won'
GROUP BY c.id
ORDER BY average_final_price DESC;

--В завданні написано: Ранжувати користувачів за загальною сумою виграних аукціонів 
--Перший варіант - ранжвування по сумі витрачених коштів на виграні лоти
SELECT u.id, u.name, SUM(bet.amount) as total_spend_amount, DENSE_RANK() OVER (ORDER BY SUM(bet.amount) DESC NULLS LAST) as user_rank
FROM "user" as u
LEFT JOIN bet ON bet.user_id = u.id AND bet.status = 'won'
GROUP BY u.id;

--Другий варіант - ранжування по кількості виграних лотів 
SELECT u.id, u.name, COUNT(bet.id) as amount_of_winning_bets, DENSE_RANK() OVER (ORDER BY COUNT(bet.id) DESC) as user_rank
FROM "user" as u
LEFT JOIN bet ON bet.user_id = u.id AND bet.status = 'won'
GROUP BY u.id;

--Знайти лоти, які не отримали жодної ставки
SELECT lot.id, lot.name 
FROM lot
WHERE NOT EXISTS (SELECT 1 FROM bet WHERE bet.lot_id = lot.id);