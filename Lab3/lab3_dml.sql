SELECT OrderID, OrderDate FROM Orders WHERE TotalAmount > 200; -- з таблиці Orders виводить OrderID та OrderDate замовлень, TotalAmount яких більше 200.
SELECT Name, Price FROM Ingredient WHERE Price < 125; -- з таблиці Ingredient виводить Name, Price інгредієнтів, що коштують менше 125.
SELECT OrderID FROM Orders WHERE CustomerID = 2; -- з таблиці Orders виводить OrderID, які належать користувачу з CustomerID = 2.
SELECT RecipeID, Name FROM Recipe WHERE EquipmentNote ILIKE '%духов%'; -- рецепти, в примітці про обладнання яких згадується духовка (ILIKE ігнорує регістр).
SELECT RecipeTasteID, TasteID, Intensity FROM RecipeTaste WHERE Intensity = 'слабо'; -- смаки, інтенсивність яких 'слабо'.

-- Додам нового користувача для майбутніх операцій з ним (отримає CustomerID = 7).
INSERT INTO Customer (UserName, Address, PhoneNumber)
VALUES
('Valeriy', 'Lviv, 18 Kleparivska Street', '+380960701234');
SELECT * FROM Customer WHERE CustomerID = 7;

-- Додам користувачу 7 замовлення на його ім'я (отримає OrderID = 10).
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(7, '2026-11-11', 260);                                  -- ВИПРАВЛЕНО: було 4, а має бути 7
SELECT * FROM Orders WHERE CustomerID = 7;

-- Додам до замовлення 10 інгредієнт 3 (Масло) у кількості 2.
INSERT INTO ItemQuantity (OrderID, IngredientID, Quantity, PriceAtOrder)
VALUES
(10, 3, 2, 130);                                         -- ВИПРАВЛЕНО: було OrderID = 4
SELECT * FROM ItemQuantity WHERE OrderID = 10;

-- Додам в рецепт 1 категорію 3 (CategoryID = 3) у кількості 100.
INSERT INTO RecipeItemQuantity (RecipeID, CategoryID, RecipeItemAmount)
VALUES
(1, 3, 100);
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 3;   -- ВИПРАВЛЕНО: було CategoryID = 2

-- Додам до рецепта 2 смак 3 (TasteID = 3) з інтенсивністю 'слабо'.
INSERT INTO RecipeTaste (RecipeID, TasteID, Intensity)
VALUES
(2, 3, 'слабо');
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 3;             -- ВИПРАВЛЕНО: було TasteID = 1

-- Зміню ціну на момент замовлення на Масло (IngredientID = 3) з 130 на 120.
-- Разом з цим оновлю TotalAmount замовлення (2 * 120 = 240).
-- Обидва UPDATE в одній транзакції: або виконаються обидва, або жоден.
SELECT * FROM ItemQuantity WHERE OrderID = 10;           -- ВИПРАВЛЕНО: було OrderID = 4
SELECT * FROM Orders WHERE OrderID = 10;
BEGIN;
UPDATE ItemQuantity SET PriceAtOrder = 120 WHERE OrderID = 10 AND IngredientID = 3;
UPDATE Orders SET TotalAmount = 240 WHERE OrderID = 10;
COMMIT;
SELECT * FROM ItemQuantity WHERE OrderID = 10;
SELECT * FROM Orders WHERE OrderID = 10;

-- Перевірка відкату: тимчасово обнуляю TotalAmount і скасовую зміну через ROLLBACK.
BEGIN;
UPDATE Orders SET TotalAmount = 0 WHERE OrderID = 10;    -- ВИПРАВЛЕНО: було OrderID = 4
SELECT * FROM Orders WHERE OrderID = 10; -- всередині транзакції сума 0.
ROLLBACK;
SELECT * FROM Orders WHERE OrderID = 10; -- після відкату сума знову 240.

-- Зміню інтенсивність смаку 3 в рецепті 2 зі 'слабо' на 'помірно'.
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 3;     -- ВИПРАВЛЕНО: було TasteID = 1 (там 'сильно', а не 'слабо')
UPDATE RecipeTaste
SET Intensity = 'помірно' WHERE RecipeID = 2 AND TasteID = 3;
SELECT RecipeTasteID, RecipeID, TasteID, Intensity
FROM RecipeTaste WHERE RecipeID = 2 AND TasteID = 3;

-- Збільшу кількість категорії 3 в рецепті 1 з 100 до 120.
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 3;   -- ВИПРАВЛЕНО: було CategoryID = 2
UPDATE RecipeItemQuantity
SET RecipeItemAmount = 120 WHERE RecipeID = 1 AND CategoryID = 3; -- ВИПРАВЛЕНО: було 0.25, а в коментарі 120
SELECT RecipeItemQuantityID, RecipeID, CategoryID, RecipeItemAmount
FROM RecipeItemQuantity WHERE RecipeID = 1 AND CategoryID = 3;

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