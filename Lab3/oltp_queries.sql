SELECT RecipeID, Name 
FROM Recipe WHERE EQUIPMENTNOTE ILIKE '%духов%';

SELECT RecipeTasteID, TasteID, Intensity 
FROM RecipeTaste WHERE Intensity = 'слабо'; 

INSERT INTO RecipeItemQuantity (RecipeID, CategoryID, RecipeItemAmount)
VALUES
(1, 2, 0.20); 

SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;

INSERT INTO RecipeTaste (RecipeID, TasteID, Intensity)
VALUES (2, 1, 'слабо');

SELECT RecipeTasteID, RecipeID, TasteID, Intensity 
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1; 
UPDATE RecipeTaste 
SET Intensity = 'помірно' WHERE RecipeID = 2 AND TasteID = 1; 
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;

SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2; 
UPDATE RecipeItemQuantity 
SET RecipeItemAmount = 0.25 WHERE RecipeID = 1 AND CategoryID = 2; 
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2; 

SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;
DELETE FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;
SELECT RecipeItemQuantityID, CategoryID, RecipeItemAmount FROM RecipeItemQuantity WHERE RecipeID = 1;

SELECT RecipeTasteID, RecipeID, TasteID, Intensity FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;
DELETE FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;
SELECT RecipeTasteID, TasteID, Intensity FROM RecipeTaste WHERE RecipeID = 2; 