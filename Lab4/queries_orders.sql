SELECT
    COUNT(*) as TotalOrders
FROM Orders;

SELECT
    MAX(TotalAmount) AS MaxTotalAmount
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

SELECT c.UserName, SUM(iq.Quantity * iq.PriceAtOrder) as sum_of_items
FROM Customer c 
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN ItemQuantity iq ON o.OrderID = iq.OrderID
GROUP BY c.UserName
ORDER BY sum_of_items DESC;

SELECT c.UserName, COUNT(o.OrderID) as orders_count
FROM Customer c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID , c.UserName;

SELECT OrderID, CustomerID, TotalAmount
FROM Orders
WHERE TotalAmount > (SELECT AVG(TotalAmount) FROM Orders);

SELECT UserName 
FROM Customer
WHERE CustomerID IN (SELECT CustomerID FROM Orders);

SELECT UserName 
FROM Customer
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);