SELECT COUNT(*) AS TotalOrders
FROM Orders;

SELECT MAX(TotalAmount) AS MaxTotalAmount
FROM Orders;

SELECT CustomerID, COUNT(*) AS total_orders, SUM(TotalAmount) AS total_sum
FROM Orders
GROUP BY CustomerID;

SELECT CustomerID, COUNT(*) AS total_orders, SUM(TotalAmount) AS total_sum
FROM Orders
GROUP BY CustomerID
HAVING SUM(TotalAmount) > 500;

SELECT c.UserName, o.OrderID, o.OrderDate, o.TotalAmount
FROM Customer c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

SELECT c.UserName, SUM(iq.Quantity * iq.PriceAtOrder) AS sum_of_items
FROM Customer c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN ItemQuantity iq ON o.OrderID = iq.OrderID
GROUP BY c.UserName
ORDER BY sum_of_items DESC;

SELECT c.UserName, COUNT(o.OrderID) AS orders_count
FROM Customer c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.UserName;

SELECT OrderID, CustomerID, TotalAmount
FROM Orders
WHERE TotalAmount > (SELECT AVG(TotalAmount) FROM Orders);

SELECT UserName
FROM Customer
WHERE CustomerID IN (SELECT CustomerID FROM Orders);

SELECT UserName
FROM Customer
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);

SELECT COUNT(*) AS total_recipes
FROM Recipe;

SELECT c.Unit,
       COUNT(*) AS items_required,
       AVG(q.RecipeItemAmount) AS avg_amount,
       MIN(q.RecipeItemAmount) AS min_amount
FROM Category c
JOIN RecipeItemQuantity q ON q.CategoryID = c.CategoryID
GROUP BY c.Unit;

SELECT Name, EquipmentNote
FROM Recipe
WHERE EquipmentNote IN (SELECT EquipmentNote
                        FROM Recipe
                        WHERE Name = 'Пиріг з яблуками');

SELECT c.Unit,
       COUNT(*) AS items_required,
       AVG(q.RecipeItemAmount) AS avg_amount,
       MIN(q.RecipeItemAmount) AS min_amount
FROM Category c
JOIN RecipeItemQuantity q ON q.CategoryID = c.CategoryID
GROUP BY c.Unit
HAVING AVG(q.RecipeItemAmount) > 2;

SELECT r.Name, COUNT(*) AS ingredients_amount
FROM Recipe r
JOIN RecipeItemQuantity q ON q.RecipeID = r.RecipeID
GROUP BY r.RecipeID, r.Name
ORDER BY ingredients_amount DESC;

SELECT r.Name AS Recipe, t.Name AS Taste
FROM Recipe r
CROSS JOIN Taste t;

SELECT c.CategoryID, c.Name AS CategoryName
FROM RecipeItemQuantity q
RIGHT JOIN Category c ON q.CategoryID = c.CategoryID
WHERE q.CategoryID IS NULL;