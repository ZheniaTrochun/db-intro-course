SELECT OrderID, OrderDate FROM Orders WHERE (TotalAmount > 200); -- з таблиці Orders виводить OrderID and OrderDate замовлень TotalAmount яких більше 200.
SELECT Name, Price FROM Ingredient WHERE (Price < 125); -- з таблиці Ingredient виводить Name, Price інградієнтів що коштують менше 125.
SELECT OrderID FROM Orders WHERE CustomerID = 2; -- з таблиці Orders виводить OrderID, які належать користувачу з CustomerID = 2.
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
-- Кількість інградієнтів обраних юзером в замовленні
INSERT INTO ItemQuantity (OrderID, IngredientID, Quantity, PriceAtOrder)
VALUES
(4, 3, 2, 130);
SELECT * FROM ItemQuantity WHERE OrderID = 4;