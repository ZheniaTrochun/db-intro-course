SELECT COUNT(*) AS total_recipes
FROM Recipe;

SELECT c.Unit,
<<<<<<< HEAD
COUNT(*) AS items_required, AVG(q.RecipeItemAmount) AS avg_amount, MIN(q.RecipeItemAmount) AS min_amount,
JOIN RecipeItemQuantity q ON q.CategoryID = c.CategoryID 
GROUP BY c.Unit;
FROM Category c

SELECT Name,EquipmentNote FROM Recipe
WHERE EquipmentNote IN (SELECT EquipmentNote 
FROM Recipe 
WHERE Name = 'Пиріг з яблуками'); 

SELECT c.Unit, 
COUNT(*) AS items_required, AVG(q.RecipeItemAmount) AS avg_amount, MIN(q.RecipeItemAmount) AS min_amount,
JOIN RecipeItemQuantity q ON q.CategoryID = c.CategoryID 
GROUP BY c.Unit
HAVING AVG(RecipeItemAmount) > 2;
FROM Category c 

SELECT r.Name 
COUNT(*) AS ingredients_amount 
FROM Recipe
JOIN RecipeItemQuantity q ON q.RecipeID = q.RecipeID
=======
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
>>>>>>> e296eee (Some fixes + added lab4_olap.sql)
GROUP BY r.RecipeID, r.Name
ORDER BY ingredients_amount DESC;

SELECT r.Name AS Recipe, t.Name AS Taste
<<<<<<< HEAD
FROM Recipe r 
CROSS JOIN Taste t;

SELECT c.CategoryID, c.Name AS CategoryName 
RIGHT JOIN Category с ON q.CategoryID = c.CategoryID 
WHERE q.RecipeItemQuantity is NULL; 
GROUP BY c.Name 
FROM RecipeItemQuantity q
=======
FROM Recipe r
CROSS JOIN Taste t;

SELECT c.CategoryID, c.Name AS CategoryName
FROM RecipeItemQuantity q
RIGHT JOIN Category c ON q.CategoryID = c.CategoryID
WHERE q.CategoryID IS NULL;
>>>>>>> e296eee (Some fixes + added lab4_olap.sql)





