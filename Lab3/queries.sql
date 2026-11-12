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
-- Кількість інградієнтів обраних юзером в замовленні.
INSERT INTO ItemQuantity (OrderID, IngredientID, Quantity, PriceAtOrder)
VALUES
(4, 3, 2, 130);
-- Зміню ціну на момент замовлення на інградієнт Масло (IngredientID = 3) з 130 на 120.
SELECT * FROM ItemQuantity WHERE OrderID = 4;
UPDATE ItemQuantity SET PriceAtOrder = 120 WHERE OrderID = 4 AND IngredientID = 3;
UPDATE Orders SET TotalAmount = 240 WHERE OrderID = 4;
SELECT * FROM ItemQuantity WHERE OrderID = 4;
-- Видаляю Customer з CustomerID = 4 та все що пов'язано з ним.
-- Видаляю спочатку ItemQuantity, бо він залежить від Orders.
SELECT * FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );
DELETE FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 ) ;
SELECT * FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );
-- Далі видаляю Orders бо він залежить від Customer.
SELECT * FROM Orders WHERE CustomerID = 4;
DELETE FROM Orders WHERE CustomerID = 4;
SELECT * FROM Orders WHERE CustomerID = 4;
-- І на фінал видаляю самого Customer, від якого залежали всі попередні видалення.
SELECT * FROM Customer WHERE CustomerID = 4;
DELETE FROM Customer WHERE CustomerID = 4;
SELECT * FROM Customer WHERE CustomerID = 4;