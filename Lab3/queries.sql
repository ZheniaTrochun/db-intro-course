SELECT OrderID, OrderDate FROM Orders WHERE (TotalAmount > 200);
SELECT Name, Price FROM Ingredient WHERE (Price < 125);
SELECT OrderID FROM Orders WHERE CustomerID = 2;

INSERT INTO Customer (UserName, Address, PhoneNumber)
VALUES
('Valeriy', 'Lviv, 18 Kleparivska Street', '+380960701234');
SELECT * FROM Customer WHERE CustomerID = 4;

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(4, '2026-11-11', 260);
SELECT * FROM Orders WHERE CustomerID = 4;

INSERT INTO ItemQuantity (OrderID, IngredientID, Quantity, PriceAtOrder)
VALUES
(4, 3, 2, 130);

SELECT * FROM ItemQuantity WHERE OrderID = 4;
UPDATE ItemQuantity SET PriceAtOrder = 120 WHERE OrderID = 4 AND IngredientID = 3;
UPDATE Orders SET TotalAmount = 240 WHERE OrderID = 4;
SELECT * FROM ItemQuantity WHERE OrderID = 4;

SELECT * FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );
DELETE FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 ) ;
SELECT * FROM ItemQuantity WHERE OrderID IN ( SELECT OrderID FROM Orders WHERE CustomerID = 4 );

SELECT * FROM Orders WHERE CustomerID = 4;
DELETE FROM Orders WHERE CustomerID = 4;
SELECT * FROM Orders WHERE CustomerID = 4;

SELECT * FROM Customer WHERE CustomerID = 4;
DELETE FROM Customer WHERE CustomerID = 4;
SELECT * FROM Customer WHERE CustomerID = 4;