SELECT OrderID, OrderDate FROM Orders WHERE (TotalAmount > 200); -- з таблиці Orders виводить OrderID та OrderDate замовлень, TotalAmount яких більше 200.
SELECT Name, Price FROM Ingredient WHERE (Price < 125); -- з таблиці Ingredient виводить Name, Price інградієнтів, що коштують менше 125.
SELECT OrderID FROM Orders WHERE CustomerID = 2; -- з таблиці Orders виводить OrderID, які належать користувачу з CustomerID = 2.
SELECT RecipeID, Name FROM Recipe WHERE EquipmentNote ILIKE '%духов%'; -- з таблиці Recipe виводить RecipeID, Name рецептів, в примітці про обладнання яких згадується духовка (ILIKE ігнорує регістр).
SELECT RecipeTasteID, TasteID, Intensity FROM RecipeTaste WHERE Intensity = 'слабо'; -- з таблиці RecipeTaste виводить смаки, інтенсивність яких 'слабо'.

-- Додам нового користувача для майбутніх операцій з ним.
INSERT INTO Customer (UserName, Address, PhoneNumber)
VALUES
('Valeriy', 'Lviv, 18 Kleparivska Street', '+380960701234');
SELECT * FROM Customer WHERE CustomerID = 4;

-- Додам користувачу замовлення на його ім'я.
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(4, '2026-11-11', 260);
SELECT * FROM Orders WHERE CustomerID = 4;

-- Кількість інградієнтів обраних юзером в замовленні.
INSERT INTO ItemQuantity (OrderID, IngredientID, Quantity, PriceAtOrder)
VALUES
(4, 3, 2, 130);
SELECT * FROM ItemQuantity WHERE OrderID = 4;

-- Додам в рецепт 1 категорію 2 (CategoryID = 2) у кількості 0.20.
INSERT INTO RecipeItemQuantity (RecipeID, CategoryID, RecipeItemAmount)
VALUES
(1, 2, 0.20);
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;

-- Додам до рецепта 2 смак 1 (TasteID = 1) з інтенсивністю 'слабо'.
INSERT INTO RecipeTaste (RecipeID, TasteID, Intensity)
VALUES
(2, 1, 'слабо');
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;

-- Зміню ціну на момент замовлення на інградієнт Масло (IngredientID = 3) з 130 на 120.
-- Разом з цим оновлю TotalAmount замовлення (2 * 120 = 240).
-- Обидва UPDATE в одній транзакції: або виконаються обидва, або жоден.
SELECT * FROM ItemQuantity WHERE OrderID = 4;
SELECT * FROM Orders WHERE OrderID = 4;
BEGIN;
UPDATE ItemQuantity SET PriceAtOrder = 120 WHERE OrderID = 4 AND IngredientID = 3;
UPDATE Orders SET TotalAmount = 240 WHERE OrderID = 4;
COMMIT;
SELECT * FROM ItemQuantity WHERE OrderID = 4;
SELECT * FROM Orders WHERE OrderID = 4;

-- Перевірка відкату: тимчасово обнуляю TotalAmount і скасовую зміну через ROLLBACK.
BEGIN;
UPDATE Orders SET TotalAmount = 0 WHERE OrderID = 4;
SELECT * FROM Orders WHERE OrderID = 4; -- всередині транзакції сума 0.
ROLLBACK;
SELECT * FROM Orders WHERE OrderID = 4; -- після відкату сума знову 240.

-- Зміню інтенсивність смаку 1 в рецепті 2 зі 'слабо' на 'помірно'.
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;
UPDATE RecipeTaste
SET Intensity = 'помірно' WHERE RecipeID = 2 AND TasteID = 1;
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;

-- Збільшу кількість категорії 2 в рецепті 1 з 0.20 до 0.25.
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;
UPDATE RecipeItemQuantity
SET RecipeItemAmount = 0.25 WHERE RecipeID = 1 AND CategoryID = 2;
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;

-- Видаляю Customer з CustomerID = 4 та все що пов'язано з ним.
-- Видаляю спочатку ItemQuantity, бо він залежить від Orders.
SELECT * FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );
DELETE FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );
SELECT * FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );

-- Далі видаляю Orders бо він залежить від Customer.
SELECT * FROM Orders WHERE CustomerID = 4;
DELETE FROM Orders WHERE CustomerID = 4;
SELECT * FROM Orders WHERE CustomerID = 4;

-- І на фінал видаляю самого Customer, від якого залежали всі попередні видалення.
SELECT * FROM Customer WHERE CustomerID = 4;
DELETE FROM Customer WHERE CustomerID = 4;
SELECT * FROM Customer WHERE CustomerID = 4;

-- Видаляю категорію 2 з рецепта 1.
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;
DELETE FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 2;
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1;

-- Видаляю смак 1 з рецепта 2.
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;
DELETE FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 1;
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2;