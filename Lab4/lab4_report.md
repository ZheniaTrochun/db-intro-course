# Лабораторна робота 4. Аналітичні SQL-запити (OLAP)

Файл зі скриптом: lab4_olap.sql. СУБД: PostgreSQL (pgAdmin).

## Опис схеми

Запити працюють з двома предметними областями: інтернет-магазин і
рецепти.

  -------------------- ---------------------------------------------------------------------- --------------------------------------------------------------
  Customer             CustomerID (PK), UserName                                              Клієнти магазину
  Orders               OrderID (PK), CustomerID (FK → Customer), OrderDate, TotalAmount       Замовлення клієнтів
  ItemQuantity         OrderID (FK → Orders), Quantity, PriceAtOrder                          Позиції замовлення з кількістю та ціною на момент замовлення
  Recipe               RecipeID (PK), Name, EquipmentNote                                     Рецепти та примітка про обладнання
  Category             CategoryID (PK), Name, Unit                                            Категорії інгредієнтів та одиниця виміру
  RecipeItemQuantity   RecipeID (FK → Recipe), CategoryID (FK → Category), RecipeItemAmount   Кількість інгредієнта певної категорії в рецепті
  Taste                Name                                                                   Довідник смаків
  -------------------- ---------------------------------------------------------------------- --------------------------------------------------------------

##  Відповідність вимогам

  ------------------------------------------------- --- ------------------------------------ ----------------------------------
  Агрегація (COUNT, SUM, AVG, MIN, MAX, GROUP BY)   4   10                                   1, 2, 3, 4, 6, 7, 11, 12, 14, 15
  Різні типи JOIN                                   3   4 типи (INNER, LEFT, RIGHT, CROSS)   5, 7, 16, 17
  Підзапити                                         3   4                                    8, 9, 10, 13
  ------------------------------------------------- --- ------------------------------------ ----------------------------------

## Опис запитів

### Магазин

Запит 1. Кількість замовлень

SELECT COUNT(\*) AS TotalOrders\
FROM Orders;

Запит 2. Найбільша сума замовлення

SELECT MAX(TotalAmount) AS MaxTotalAmount\
FROM Orders;

Запит 3. Замовлення по клієнтах

SELECT CustomerID, COUNT(\*) AS total_orders, SUM(TotalAmount) AS
total_sum\
FROM Orders\
GROUP BY CustomerID;

Запит 4. Клієнти із сумою понад 500

SELECT CustomerID, COUNT(\*) AS total_orders, SUM(TotalAmount) AS
total_sum\
FROM Orders\
GROUP BY CustomerID\
HAVING SUM(TotalAmount) \> 500;

Запит 5. INNER JOIN: замовлення з іменами клієнтів

SELECT c.UserName, o.OrderID, o.OrderDate, o.TotalAmount\
FROM Customer c\
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

Запит 6. Багатотабличні агрегація: сума покупок клієнта

SELECT c.UserName, SUM(iq.Quantity \* iq.PriceAtOrder) AS sum_of_items\
FROM Customer c\
JOIN Orders o ON c.CustomerID = o.CustomerID\
JOIN ItemQuantity iq ON o.OrderID = iq.OrderID\
GROUP BY c.UserName\
ORDER BY sum_of_items DESC;

Запит 7. LEFT JOIN: кількість замовлень з урахуванням клієнтів без
замовлень

SELECT c.UserName, COUNT(o.OrderID) AS orders_count\
FROM Customer c\
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID\
GROUP BY c.CustomerID, c.UserName;

Запит 8. Підзапит у WHERE: замовлення вище середнього

SELECT OrderID, CustomerID, TotalAmount\
FROM Orders\
WHERE TotalAmount \> (SELECT AVG(TotalAmount) FROM Orders);

Запит 9. Підзапит IN: клієнти, які робили замовлення

SELECT UserName\
FROM Customer\
WHERE CustomerID IN (SELECT CustomerID FROM Orders);

Запит 10. Підзапит NOT IN: клієнти без замовлень

SELECT UserName\
FROM Customer\
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);

### Рецепти

Запит 11. Кількість рецептів

SELECT COUNT(\*) AS total_recipes\
FROM Recipe;

Запит 12. Статистика інгредієнтів за одиницею виміру

SELECT c.Unit,\
COUNT(\*) AS items_required,\
AVG(q.RecipeItemAmount) AS avg_amount,\
MIN(q.RecipeItemAmount) AS min_amount\
FROM Category c\
JOIN RecipeItemQuantity q ON q.CategoryID = c.CategoryID\
GROUP BY c.Unit;

Запит 13. Підзапит: рецепти з тим самим обладнанням

SELECT Name, EquipmentNote\
FROM Recipe\
WHERE EquipmentNote IN (SELECT EquipmentNote\
FROM Recipe\
WHERE Name = \'Пиріг з яблуками\');

Запит 14. Групи з середньою кількістю понад 2

SELECT c.Unit,\
COUNT(\*) AS items_required,\
AVG(q.RecipeItemAmount) AS avg_amount,\
MIN(q.RecipeItemAmount) AS min_amount\
FROM Category c\
JOIN RecipeItemQuantity q ON q.CategoryID = c.CategoryID\
GROUP BY c.Unit\
HAVING AVG(q.RecipeItemAmount) \> 2;

Запит 15. Кількість інгредієнтів у кожному рецепті

SELECT r.Name, COUNT(\*) AS ingredients_amount\
FROM Recipe r\
JOIN RecipeItemQuantity q ON q.RecipeID = r.RecipeID\
GROUP BY r.RecipeID, r.Name\
ORDER BY ingredients_amount DESC;

Запит 16. CROSS JOIN: усі комбінації рецепт і смак

SELECT r.Name AS Recipe, t.Name AS Taste\
FROM Recipe r\
CROSS JOIN Taste t;

Запит 17. RIGHT JOIN: категорії, не використані в жодному рецепті

SELECT c.CategoryID, c.Name AS CategoryName\
FROM RecipeItemQuantity q\
RIGHT JOIN Category c ON q.CategoryID = c.CategoryID\
WHERE q.CategoryID IS NULL;
